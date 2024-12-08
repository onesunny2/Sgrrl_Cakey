//
//  Cake3DDecoViewTest.swift
//  Cakey
//
//  Created by dora on 11/19/24.
//
import Foundation
import SwiftUI
import ARKit
import RealityKit
import Combine

// 🪵 BackLogs
// TODO: 반응형, 동적 사이즈 조절
// TODO: Mode 업데이트 시, 카메라 원위치

// MARK: - CakeDecoView에 들어갈 3D
struct Cake3DDecoView: View {
    var coordinator_deco : Coordinator_deco
    @State private var cameraHeight: Float = 1.5
    @State private var activeMode: EditMode = .editMode
    
    var topView: CameraMode = CameraMode.topView
    var sideView: CameraMode = CameraMode.sideView
    
    var viewModel: CakeyViewModel
    
    var body: some View {
        VStack{
            // MARK: - Cake3D
            ZStack{
                VStack{
                    Spacer().frame(height: 150)
                    ARViewContainer_deco(coordinator_deco: coordinator_deco, cameraHeight: $cameraHeight, activeMode: $activeMode, viewModel: viewModel).ignoresSafeArea()
                    
                    // MARK: - DecoMode
                    if activeMode == .editMode {
                        VStack {
                            
                            // MARK: 전체, 개별 삭제
                            HStack(spacing: 10) {
                                DecoActionCell(buttonColor: .cakeyOrange3, symbolName: "arrow.trianglehead.2.clockwise.rotate.90", buttonAction: {
                                    coordinator_deco.deleteAll()
                                })
                                DecoActionCell(buttonColor: .cakeyOrange1, symbolName: "multiply",buttonText: "선택 삭제", buttonAction: {
                                    coordinator_deco.deleteOne()
                                })
                            } .padding(.bottom, 10)
                            
                            // MARK: ImageSelect
                            ImageScrollView(imgList: viewModel.cakeyModel.cakeImages) { imgData in
                                coordinator_deco.addDecoEntity(imgData: imgData)
                            }
                            .padding(.leading, 23)
                        }
                    }
                }
                
                HStack{
                    Spacer()
                    VerticalSlider(value: $cameraHeight, range: sideView.cameraHeight...topView.cameraHeight)
                        .frame(width: 20, height: 300)
                        .padding()
                        .background(.clear)
                }
            }
            
            // MARK: Mode Select
            ModeSelectView(activeMode: $activeMode) { mode in
                withAnimation {
                    activeMode = mode
                }
                coordinator_deco.activeMode = mode
            }
            .padding(.top, 20)
        }
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
    
    var viewModel: CakeyViewModel
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: true)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel - Cake
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        
        let selectedColor = Color(hex:viewModel.cakeyModel.cakeColor!)
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        cakeModel.name = "cake"
        
        // MARK: CakeModel - CakeTray
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        cakeTrayModel.name = "cake"
        
        // MARK: CakeModel - Cake + CakeTray
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        
        coordinator_deco.cakeParentEntity = cakeParentEntity
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        // MARK: Highlight Anchor
        let highLightAnchor = AnchorEntity(world: [0,0,0])
        coordinator_deco.highlightAnchor = highLightAnchor
        arView.scene.addAnchor(highLightAnchor)
        
        // MARK: CakeAnchor
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
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
            print("현재 케이크의 크기:\(cakeParentEntity.scale(relativeTo: nil))")
            
            // MARK: 모델 사이즈 Clamp
            coordinator_deco.clampCakeSize()
            coordinator_deco.clampDecoPosition()
        } as? AnyCancellable
        
        coordinator_deco.arView = arView
        coordinator_deco.initializeGestures()
        coordinator_deco.updateMode()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // MARK: 슬라이더 연동 Camera 높이값 변동
        context.coordinator.camera?.position.y = cameraHeight * 0.5
        context.coordinator.camera?.position.x = cameraHeight * 0.2
        
        // MARK: 살펴보기 vs 수정하기 모드
        coordinator_deco.updateMode()
    }
    
    func makeCoordinator() -> Coordinator_deco {
        return Coordinator_deco()  // 코오디네이터 1
    }
}

class Coordinator_deco: NSObject, ObservableObject {
    var arView: ARView?
    var highlightAnchor: AnchorEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    var activeMode: EditMode = .editMode
    var decoEntities = DecoEntities.shared
    
    @Published var selectedEntity: ModelEntity? {
        // MARK: 변경된 직후에 실행되는 관찰자
        didSet {
            // LongPress된 대상에 선택 삭제
            if selectedEntity != oldValue {
                //blinkEntity(selectedEntity)
                highlightEntity(selectedEntity)
            }
        }
    }
    
    // MARK: 수정하기 vs 살펴보기 모드
    func updateMode() {
        guard let cakeParentEntity = cakeParentEntity else { return }
        // TODO: Mode 업데이트 시, 카메라 원위치
        
        // MARK: CakeParentEntity 안에서 name으로 제스처 구분!
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
    func addDecoEntity(imgData: Data) {
        
        print("deco뷰에서의 imgData: \(imgData)")
        guard let arView = arView, let cakeParentEntity = cakeParentEntity else { return }
        
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let plane = ModelEntity(mesh: planeMesh)
        
        if let uiImage = UIImage(data: imgData),
           let cgImage = uiImage.cgImage {
            do {
                let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                var material = UnlitMaterial()
                material.color = .init(tint: .white, texture: .init(texture))
                material.opacityThreshold = 0.1
                plane.model?.materials = [material]
            } catch {
                print("텍스처 만들기 실패!: \(error.localizedDescription)")
            }
        }
        
        plane.position.y += 0.79 * 0.43 + 0.02
        plane.scale /= 2
        
        plane.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: plane)
        
        // name으로 imgData 접근할 수 있게!
        plane.name = "deco+\(imgData)"
        
        // cakeParentEntity에 추가
        cakeParentEntity.addChild(plane)
        
        decoEntities.decoEntities.append(DecoEntity(id: plane.id, image: imgData, position: plane.position(relativeTo: nil),scale: plane.scale(relativeTo: nil), orientation: plane.orientation(relativeTo: nil)))
    }
    
    // MARK: 전체 삭제 - 버튼 할당
    func deleteAll() {
        guard let cakeParentEntity = cakeParentEntity else { return }
        // deco 전체 삭제
        for entity in cakeParentEntity.children.filter({ $0.name.starts(with: "deco") }) {
            cakeParentEntity.removeChild(entity)
        }
        
        decoEntities.decoEntities.removeAll()
        highlightAnchor?.children.removeAll()
    }
    
    
    // MARK: 선택 삭제 - 버튼 할당
    func deleteOne(){
        guard let selectedEntity = selectedEntity else { return }
        cakeParentEntity?.removeChild(selectedEntity)
        highlightAnchor?.children.removeAll()
        self.selectedEntity = nil
        
        // MARK: id 비교 후 삭제 - 성공!
        if let index = decoEntities.decoEntities.firstIndex(where: { $0.id == selectedEntity.id }) {
            decoEntities.decoEntities.remove(at: index)
            print("삭제완료!")
        } else {
            print("선택된 엔티티가 decoEntities에 없음")
        }
    }
    
    // MARK: LongPress 제스처 추가 함수
    func setupLongPressGeture(){
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        arView?.addGestureRecognizer(longPressRecognizer)
        
    }
    
    // MARK: Tap 제스처 추가 함수
    func setupTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView?.addGestureRecognizer(tapRecognizer)
    }
    
    func initializeGestures() {
        setupLongPressGeture()
        setupTapGesture()
    }
    
    // MARK: LongPress한 물체 select
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let arView = arView else { return }
        let location = gesture.location(in: arView)
        if let entity = arView.entity(at: location) as? ModelEntity {
            selectedEntity = entity
        }
    }
    
    // MARK: Tap 제스쳐
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = arView else { return }
        let tappedLocation = recognizer.location(in: arView)
        let hitResults = arView?.hitTest(tappedLocation)
        
        if let tappedEntity = hitResults?.first?.entity as? ModelEntity {
            // 선택된 엔티티와 hitTest로 탐지된 엔티티가 다르면 선택 해제
            if selectedEntity != tappedEntity {
                self.selectedEntity = nil
                highlightAnchor?.children.removeAll()
            }
        }else{
            // hitTest 결과가 없거나, 맞은 엔티티가 없는 경우 하이라이트 초기화
            self.selectedEntity = nil
            highlightAnchor?.children.removeAll()
        }
        
    }
    
    
    // MARK: highlight 함수
    private func highlightEntity(_ entity: ModelEntity?) {
        guard let entity = entity else { return }
        
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let plane = ModelEntity(mesh: planeMesh)
        
        if let texture = try? TextureResource.load(named: "selectHighlight") {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            material.opacityThreshold = 0.1
            plane.model?.materials = [material]
        }
        
        plane.scale = entity.scale(relativeTo: nil)
        plane.position = entity.position(relativeTo: nil)
        plane.orientation = entity.orientation(relativeTo: nil)
        
        highlightAnchor?.addChild(plane)
    }
    
    
    // MARK: blink 함수 - 안쓰지만 남겨둠!
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
    
    // MARK: 케이크 사이즈 Clamp
    func clampCakeSize() {
        guard let cakeModel = cakeParentEntity else { return }
        
        let minScale: Float = 0.5
        let maxScale: Float = 1.2
        let currentScale = cakeModel.scale(relativeTo: nil).x
        
        if currentScale < minScale {
            let clampedScale = SIMD3<Float>(repeating: minScale)
            cakeModel.scale = clampedScale
        } else if currentScale > maxScale {
            let clampedScale = SIMD3<Float>(repeating: maxScale)
            cakeModel.scale = clampedScale
        }
    }
    
    // MARK: 데코 위치 Clamp
    func clampDecoPosition() {
        
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        let radius: Float = 0.35 // 대강의 원의 반지름
        
        for entity in cakeParentEntity.children.filter({ $0.name.starts(with: "deco") }) {
            var position = entity.position(relativeTo: cakeParentEntity)
            let distanceSquared = position.x * position.x + position.z * position.z
            
            // 원 밖으로 나갔을 경우 위치 제한
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
    
    // MARK: 데코 저장 - 완료 버튼 누르면 실시
    func saveDecoEntity(){
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        for entity in cakeParentEntity.children.filter({ $0.name.starts(with: "deco")}){
            if let index = decoEntities.decoEntities.firstIndex(where: { $0.id == entity.id }) {
                decoEntities.decoEntities[index].position = entity.position(relativeTo: nil)
                decoEntities.decoEntities[index].scale = entity.scale(relativeTo: nil)
                decoEntities.decoEntities[index].orientation = entity.orientation(relativeTo: nil)
            } else {
                print("해당 id를 가진 decoEntity를 찾지 못함!")
            }
        }
    }
    
    // TODO: 백로그 케이크 사이즈 clamp시 뽀용 애니메이션 적용
    private func applyScaleWithEaseOut(entity: ModelEntity, targetScale: SIMD3<Float>) {
        let animationDuration: TimeInterval = 0.3
        let frameInterval: TimeInterval = 0.01
        let totalFrames = Int(animationDuration / frameInterval)
        
        let currentScale = entity.scale(relativeTo: nil)
        var frame = 0
        
        Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { timer in
            if frame >= totalFrames {
                timer.invalidate()
                entity.setScale(targetScale, relativeTo: nil)
                return
            }
            
            let t = Float(frame) / Float(totalFrames) // 0 ~ 1 사이의 값
            let easeOutProgress = 1 - pow(1 - t, 3)  // Ease-out 곡선
            let interpolatedScale = mix(currentScale, targetScale, t: easeOutProgress)
            
            entity.setScale(interpolatedScale, relativeTo: nil)
            frame += 1
        }
    }
    
}



