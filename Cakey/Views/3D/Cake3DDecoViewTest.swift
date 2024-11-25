//
//  Cake3DDecoViewTest.swift
//  Cakey
//
//  Created by dora on 11/19/24.
//


import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: 수정모드, 살펴보기모드
enum EditMode{
    case editMode
    case lookMode
}

// MARK: - CakeDecoView에 들어갈 3D
struct Cake3DDecoView: View {
    @StateObject private var coordinator_deco = Coordinator_deco()
    @State private var cameraHeight: Float = 0.8
    
    @State private var activeMode: EditMode = .editMode
    
    var topView: CameraMode = CameraMode.topView
    var sideView: CameraMode = CameraMode.sideView
    
    // TODO: - 데이터에서 불러오기
    var imgList: [String] = ["p6", "p2","p3","p4","p5"]
    
    var body: some View {
        // MARK: - Cake3D
        ZStack{
            ARViewContainer_deco(coordinator_deco: coordinator_deco, cameraHeight: $cameraHeight, activeMode: $activeMode).ignoresSafeArea()
            
            HStack{
                Spacer()
                VerticalSlider(value: $cameraHeight, range: sideView.cameraHeight...topView.cameraHeight)
                    .frame(width: 20, height: 300)
                    .padding()
                    .background(.clear)
            }
        }
        
        // MARK: - DecoMode
        if activeMode == .editMode {
            VStack {
                // MARK: 전체, 개별 삭제
                HStack(spacing: 10) {
                    DecoActionCell(buttonColor: .cakeyOrange3, symbolName: "arrow.trianglehead.2.clockwise.rotate.90", buttonAction: {
                        coordinator_deco.deleteAll()
                    })
                    DecoActionCell(buttonColor: .cakeyOrange1, symbolName: "trash",buttonText: "선택 삭제", buttonAction: {
                        coordinator_deco.deleteOne()
                    })
                } .padding(.bottom, 10)
                
                // MARK: 이미지 Cell
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            if index < imgList.count {
                                let img = imgList[index]
                                Button(action: {
                                    coordinator_deco.addDecoEntity(imgName: img)
                                    print("버튼 눌렀다!")
                                }) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.clear)
                                        .frame(width: 80, height: 80)
                                        .overlay {
                                            ZStack {
                                                Image("\(img)")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.cakeyOrange1, lineWidth: 2)
                                                    .padding(1)
                                            }
                                        }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.cakeyOrange2)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.symbolTitle2)
                                            .foregroundStyle(.cakeyOrange3)
                                    }
                            }
                        }
                        
                    }
                }
                .padding(.leading, 30)
            }
        }
        
        // MARK: - Mode Select
        VStack {
            HStack(spacing: 30) {
                if activeMode == .editMode {
                    Circle()
                        .fill(.cakeyOrange1)
                        .frame(width: 8)
                        .offset(x: -45)
                        .transition(.opacity)
                } else if activeMode == .lookMode {
                    Circle()
                        .fill(.cakeyOrange1)
                        .frame(width: 8)
                        .offset(x: +45)
                        .transition(.opacity)
                }
            }
            
            HStack(spacing: 30) {
                Button(action: {
                    withAnimation {
                        coordinator_deco.activeMode = .editMode
                        activeMode = .editMode
                    }
                }) {
                    VStack {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(activeMode == .editMode ? .cakeyOrange1 : .gray)
                        Text("수정하기")
                            .foregroundColor(activeMode == .editMode ? .cakeyOrange1 : .gray)
                    }
                }
                
                Button(action: {
                    withAnimation {
                        activeMode = .lookMode
                    }
                    coordinator_deco.activeMode = .lookMode
                }) {
                    VStack {
                        Image(systemName: "eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(activeMode == .lookMode ? .cakeyOrange1 : .gray)
                        Text("살펴보기")
                            .foregroundColor(activeMode == .lookMode ? .cakeyOrange1 : .gray)
                    }
                }
            }
        }.padding(.top, 20)
    }
}

//TODO: 분리
let decoGroup = CollisionGroup(rawValue: 1 << 0)
let cakeGroup = CollisionGroup(rawValue: 1 << 1)
let ringGroup = CollisionGroup(rawValue: 1 << 2)


// MARK: - ARViewContainer
struct ARViewContainer_deco: UIViewRepresentable {
    @ObservedObject var coordinator_deco: Coordinator_deco  // 코오디네이터 1
    @Binding var cameraHeight: Float
    @Binding var activeMode: EditMode
    
    // TODO: - 색상 데이터 불러오기
    var selectedColor: Color = .cakeyOrange2
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel - Cake
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        cakeModel.name = "cake"
        //cakeModel.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        // MARK: CakeModel - CakeSurface
        let cakeSurfaceModel = try! ModelEntity.loadModel(named: "cakeSurface")
        var cakeMat = PhysicallyBasedMaterial()
        cakeMat.baseColor = .init(tint: .white.withAlphaComponent(0))
        cakeMat.opacityThreshold = 0
        
        cakeSurfaceModel.model?.materials = [cakeMat]
        cakeSurfaceModel.scale = SIMD3(repeating: 0.43)
        //cakeSurfaceModel.position.y -= 0.05
        cakeSurfaceModel.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        
        // MARK: CakeModel - CakeTray
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        cakeTrayModel.name = "cake"
        
        // MARK: CakeModel - Cake + CakeTray
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        cakeParentEntity.addChild(cakeSurfaceModel)
        cakeParentEntity.generateCollisionShapes(recursive: true)
        
        
        coordinator_deco.cakeParentEntity = cakeParentEntity
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        // MARK: DecoAnchor
        let decoAnchor = AnchorEntity(world: [0,0,0])
        
        coordinator_deco.decoAnchor = decoAnchor
        cakeParentEntity.addChild(decoAnchor)
        
        // MARK: CakeAnchor
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        cakeAnchor.addChild(decoAnchor)
        arView.scene.addAnchor(cakeAnchor)
        
        
        // MARK: CakeRing
        let ringAnchor = AnchorEntity(world: [0,0,0])
        coordinator_deco.ringAnchor = ringAnchor
        //coordinator_deco.makeRing()
        
        arView.scene.addAnchor(ringAnchor)
        
        // MARK: Virtual Camera
        let camera = PerspectiveCamera()
        camera.position = [0, cameraHeight, 1]
        context.coordinator.camera = camera
        
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        
        // MARK: updateUI에서 감지 못하는 SceneEvent 구독
        context.coordinator.cancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            // MARK: 카메라 각도 조정
            camera.look(at: cakeParentEntity.position, from: camera.position, relativeTo: nil)
            // MARK: 모델 사이즈 Clamp
            context.coordinator.clampCakeSize()
            
            coordinator_deco.clampDecoPosition()
        } as? AnyCancellable
        
        
        
        coordinator_deco.arView = arView
        coordinator_deco.setupLongPressGeture()
        coordinator_deco.updateMode()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // MARK: 슬라이더 연동 Camera 높이값 변동
        context.coordinator.camera?.position.y = cameraHeight
        context.coordinator.camera?.position.x = cameraHeight * 0.6
        //context.coordinator.cakeParentEntity?.scale *= cameraHeight * 1.2
        
        coordinator_deco.updateMode()
        
    }
    
    func makeCoordinator() -> Coordinator_deco {
        return Coordinator_deco()   // 코오디네이터 2
    }
}

class Coordinator_deco: NSObject, ObservableObject {
    var arView: ARView?
    var decoAnchor:  AnchorEntity?
    var cakeParentEntity: ModelEntity?
    var ringAnchor: AnchorEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    var activeMode: EditMode = .editMode
    
    var cancellables = Set<AnyCancellable>()
    
    
    @Published var selectedEntity: ModelEntity? {
        // MARK: 변경된 직후에 실행되는 관찰자
        didSet {
            // LongPress된 대상에 blink
            if selectedEntity != oldValue {
                blinkEntity(selectedEntity)
            }
        }
    }
    
    func updateMode() {
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        // CakeParentEntity안에서 cake tag로 제스처 구분!
        switch activeMode {
        case .editMode:
            cakeParentEntity.children.forEach { entity in
                if let entity = entity as? ModelEntity{
                    if entity.name == "cake"{
                        entity.collision?.filter = CollisionFilter(group: cakeGroup, mask: [])
                    }else{
                        entity.collision?.filter = CollisionFilter(group: decoGroup, mask: [.all])
                    }
                }
            }
            
        case .lookMode:
            cakeParentEntity.children.forEach { entity in
                if let entity = entity as? ModelEntity{
                    if entity.name == "cake"{
                        entity.collision?.filter = CollisionFilter(group: cakeGroup, mask: [.all])
                    }else{
                        entity.collision?.filter = CollisionFilter(group: decoGroup, mask: [])
                    }
                }
            }
        }
    }
    
    
    // MARK: 데코 추가 함수
    func addDecoEntity(imgName: String) {
        guard let arView = arView, let cakeParentEntity = cakeParentEntity else { return }
        
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let plane = ModelEntity(mesh: planeMesh)
        
        if let texture = try? TextureResource.load(named: imgName) {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            material.opacityThreshold = 0.1
            plane.model?.materials = [material]
        }
        
        plane.position.y += 0.79 * 0.43 + 0.02
        plane.scale /= 2
        
        plane.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: plane)
        plane.name = "deco"
        
        plane.collision = CollisionComponent(shapes:[ShapeResource.generateBox(width: 0.5, height: 0.1, depth: 0.5)], mode: .trigger, filter: .sensor)
        plane.physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: .default,
            mode: .dynamic
        )
        
        // decoAnchor 대신 cakeParentEntity에 추가
        cakeParentEntity.addChild(plane)
        
        // ringGroup과 충돌하면! 속도 고정, y값 고정 하고 싶은거야!
            arView.scene.subscribe(to: SceneEvents.Update.self) { [weak plane] _ in
                guard let plane = plane else { return }
                
                plane.physicsMotion?.angularVelocity = SIMD3(repeating: 0)
                plane.physicsMotion?.linearVelocity = SIMD3(repeating: 0)
                plane.position.y = 0.79 * 0.43 + 0.02 // 고정된 y-position 값
            }.store(in: &cancellables)
        
        arView.scene.subscribe(to: CollisionEvents.Began.self) { [weak self, weak plane] event in
                guard let plane = plane else { return }
                
                if event.entityA == plane || event.entityB == plane {
                    // 속도를 0으로 설정
                    plane.physicsMotion?.linearVelocity = .zero
                    plane.physicsMotion?.angularVelocity = .zero
                }
            }.store(in: &cancellables)
    }
    
    
    // MARK: 전체 삭제 - 버튼 할당
    func deleteAll() {
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        // "cake" 이름이 아닌 모든 자식을 순회하며 제거
        for entity in cakeParentEntity.children.filter({ $0.name != "cake" }) {
            cakeParentEntity.removeChild(entity)
        }
        
        print("모든 데코가 삭제되었습니다.")
    }
    
    
    // MARK: 선택 삭제 - 버튼 할당
    func deleteOne(){
        guard let selectedEntity = selectedEntity else { return }
        cakeParentEntity?.removeChild(selectedEntity)
        self.selectedEntity = nil
    }
    
    // MARK: LongPress 제스처 추가 함수
    func setupLongPressGeture(){
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        arView?.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: LongPress한 물체 select
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let arView = arView else { return }
        let location = gesture.location(in: arView)
        
        if let entity = arView.entity(at: location) as? ModelEntity {
            selectedEntity = entity
        }
    }
    
    // MARK: blink 함수
    private func blinkEntity(_ entity: ModelEntity?) {
        guard let entity = entity else { return }
        
        let originalMaterial = entity.model?.materials.first
        var isRed = false
        
        // 0.3초 간격으로 blink
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            guard self.selectedEntity == entity else {
                timer.invalidate()
                entity.model?.materials = [originalMaterial!]
                return
            }
            isRed.toggle()
            
            var selectedMaterial = UnlitMaterial(color: .cakeyOrange1)
            selectedMaterial.opacityThreshold = 0.1
            
            entity.model?.materials = [isRed ? selectedMaterial : originalMaterial!]
        }
    }
    
    // MARK: 모델 사이즈 Clamp
    func clampCakeSize() {
        guard let model = cakeParentEntity else { return }
        
        let currentScale = model.scale.x
        var newScale = currentScale
        
        if currentScale < 0.5 {
            newScale = max(currentScale, 0.5)
        }
        
        if currentScale > 2.5 {
            newScale = min(currentScale, 2.5)
        }
        
        if newScale != currentScale {
            model.scale = SIMD3(repeating: newScale)
        }
    }
    
    func makeRing() {
        let radius: Float = 0.5
        let cubeSize: Float = 0.1

        // 큐브의 개수 (원을 구성할 큐브의 수)
        let cubeCount = 60

        for i in 0..<cubeCount {
            let angle = Float(i) * (2 * .pi / Float(cubeCount))
            
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            
            var cakeMat = PhysicallyBasedMaterial()
            cakeMat.baseColor = .init(tint: .white.withAlphaComponent(0))
            cakeMat.opacityThreshold = 0
            
            let cube = ModelEntity(mesh: MeshResource.generateBox(size: cubeSize), materials: [cakeMat])
            cube.generateCollisionShapes(recursive: true)
            cube.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)

            cube.position = simd_make_float3(x, 0.79 * 0.43 + 0.01, z) // y는 큐브가 바닥에 닿도록 설정
            
            cube.collision = CollisionComponent(
                shapes: [ShapeResource.generateBox(size: SIMD3(repeating: cubeSize))],
                mode: .trigger,
                filter: CollisionFilter(group: ringGroup, mask: decoGroup)
            )
            
            ringAnchor?.addChild(cube)
        }
    }
    
    func clampDecoPosition() {
        
        guard let cakeParentEntity = cakeParentEntity else { return }

        let radius: Float = 0.4 // 원의 반지름

        // CakeParentEntity의 자식 엔터티 중 "deco" 이름을 가진 엔터티만 순회
        for entity in cakeParentEntity.children.filter({ $0.name == "deco" }) {
            var position = entity.position(relativeTo: nil)
            print("deco의 위치는\(position)")
            
            let distanceSquared = position.x * position.x + position.z * position.z
            
            // 원 밖으로 나갔을 경우
            if distanceSquared > radius * radius {
                print("clampDecoPosition")
                let distance = sqrt(distanceSquared)
                let clampedX = position.x * (radius / distance)
                let clampedZ = position.z * (radius / distance)
                
                position.x = clampedX
                position.z = clampedZ
                entity.position = position
            }
        }
    }


}



#Preview {
    CakeDecorationView(value: 4, path: .constant([4]))
}

