//
//  Cake3DView.swift
//  Cakey
//
//  Created by dora on 11/7/24.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

// 수정 모드를 나누거나, cake와 plane같이 스케일 조정할 수 있게 해야함.

// TODO:gesture 넣었다 뺐다

// TODO: enum형으로 바꾸기
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
    var imgList: [String] = ["p1", "p2","p3","p4","p5"]
    
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
                HStack(spacing: 30) {
                    DecoActionCell(buttonColor: .cakeyOrange3, symbolName: "arrow.trianglehead.2.clockwise.rotate.90", buttonAction: {
                        coordinator_deco.deleteAll()
                    })
                    DecoActionCell(buttonColor: .cakeyOrange1, symbolName: "trash",buttonText: "선택 삭제", buttonAction: {
                        coordinator_deco.deleteOne()
                    })
                } .padding(.bottom, 40)
                
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
                .padding(.leading, (UIScreen.main.bounds.width - 292) / 2)
            }
        }
        
        // MARK: - Mode Select
        VStack {
            HStack(spacing: 30) {
                if activeMode == .editMode {
                    Image(systemName: "arrowtriangle.down.fill")
                        .offset(x: -45)
                        .transition(.opacity)
                } else if activeMode == .lookMode {
                    Image(systemName: "arrowtriangle.down.fill")
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
                        Image(systemName: "pencil")
                            .foregroundColor(activeMode == .editMode ? .blue : .gray)
                        Text("수정하기")
                            .foregroundColor(activeMode == .editMode ? .blue : .gray)
                    }
                }
                
                Button(action: {
                    withAnimation {
                        activeMode = .lookMode
                    }
                    coordinator_deco.activeMode = .lookMode
                }) {
                    VStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(activeMode == .lookMode ? .blue : .gray)
                        Text("살펴보기")
                            .foregroundColor(activeMode == .lookMode ? .blue : .gray)
                    }
                }
            }
        }.padding(.top, 30)
    }
}

//TODO: 분리
let decoGroup = CollisionGroup(rawValue: 1 << 0)
let cakeGroup = CollisionGroup(rawValue: 1 << 1)


// MARK: - ARViewContainer
struct ARViewContainer_deco: UIViewRepresentable {
    @ObservedObject var coordinator_deco: Coordinator_deco  // 코오디네이터 1
    @Binding var cameraHeight: Float
    @Binding var activeMode: EditMode
    
    // TODO: - 색상 데이터 불러오기
    var selectedColor: Color = .white
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel - Cake
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        
        // MARK: CakeModel - CakeTray
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        // MARK: CakeModel - Cake + CakeTray
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        cakeParentEntity.generateCollisionShapes(recursive: true)
        cakeParentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [1, 1, 1])])
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        coordinator_deco.cakeParentEntity = cakeParentEntity
        
        // MARK: 데코 달아줄 entity
        let emptyAnchor = AnchorEntity(world: [0,0,0])
        
        coordinator_deco.emptyAnchor = emptyAnchor
        arView.scene.addAnchor(emptyAnchor)
        
        // MARK: CakeAnchor
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        cakeAnchor.addChild(emptyAnchor)
        arView.scene.addAnchor(cakeAnchor)
        
    
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
        } as? AnyCancellable
        
        coordinator_deco.arView = arView
        coordinator_deco.setupLongPressGeture()
        coordinator_deco.updateMode()
        
        // TODO:
        //coordinator_deco.activeMode = activeMode

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
    var emptyAnchor:  AnchorEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    var activeMode: EditMode = .editMode
    
    @Published var selectedEntity: ModelEntity? {
        // MARK: 변경된 직후에 실행되는 관찰자
        didSet {
            // LongPress된 되상에 blink
            if selectedEntity != oldValue {
                blinkEntity(selectedEntity)
            }
        }
    }
    
    func updateMode() {
        guard let arView = arView else { return }
        
        switch activeMode {
        case .editMode:
            print("현재 수정모드이고, ")
            emptyAnchor?.children.forEach { entity in
                if let decoEntity = entity as? ModelEntity {
                    decoEntity.collision?.filter = CollisionFilter(group: decoGroup, mask: .all)
                }
            }
            
            // 여기가 이상한듯한데 어떻게 해야하지
            if let cakeParentEntity = cakeParentEntity {
                print("cakeParentEntity에 무언가 담김!")
                cakeParentEntity.collision?.filter = CollisionFilter(group: cakeGroup, mask: [])
                arView.installGestures([.rotation, .scale], for: cakeParentEntity)
            }
            print("수정 모드 활성화: 데코만 제스처 작용")
            
        case .lookMode:
            emptyAnchor?.children.forEach { entity in
                if let decoEntity = entity as? ModelEntity {
                    decoEntity.collision?.filter = CollisionFilter(group: decoGroup, mask: [])
                }
            }
            if let cakeParentEntity = cakeParentEntity {
                arView.installGestures([.rotation, .scale], for: cakeParentEntity)
                cakeParentEntity.collision?.filter = CollisionFilter(group: cakeGroup, mask: .all)
            }
            print("살펴보기 모드 활성화: 케이크만 제스처 작용")
            
      
        }
    }


    

    // MARK: 데코 추가 함수
    func addDecoEntity(imgName: String) {
        guard let arView = arView else { return }

        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let plane = ModelEntity(mesh: planeMesh)
        
        if let texture = try? TextureResource.load(named: imgName) {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            material.opacityThreshold = 0.1
            plane.model?.materials = [material]
        }
        
//        plane.position.y += 0.79 * 0.43 + 0.03
//        plane.scale /= 3
        
        plane.position.y += 0.79 * 0.43 + 0.05
        plane.scale /= 2

        plane.generateCollisionShapes(recursive: true)
        //plane.collision = CollisionComponent(shapes:[ShapeResource.generateBox(size: [0.3,0.3,0.3])])
        //plane.collision?.filter = cakeFilter
        arView.installGestures([.all], for: plane)

        emptyAnchor?.addChild(plane)
        
        
    }
    
    // MARK: 전체 삭제 - 버튼 할당
    func deleteAll(){
        guard let emptyAnchor = emptyAnchor else { return }
        emptyAnchor.children.removeAll()
    }
    
    // MARK: 선택 삭제 - 버튼 할당
    func deleteOne(){
        guard let selectedEntity = selectedEntity else { return }
        emptyAnchor?.removeChild(selectedEntity)
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
}


#Preview {
    //Cake3DDecoView()
    CakeDecorationView(value: 4, path: .constant([4]))
}

// 높이 계산이 어떻게 되고 있는지 봐야 함..
