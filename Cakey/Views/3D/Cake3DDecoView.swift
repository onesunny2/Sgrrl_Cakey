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


// MARK: - CakeDecoView에 들어갈 3D
struct Cake3DDecoView: View {
    @State private var cameraHeight: Float = 0.8
    var topView: CameraMode = CameraMode.topView
    var sideView: CameraMode = CameraMode.sideView
    
    var body: some View {
        ZStack{
            ARViewContainer_deco(cameraHeight: $cameraHeight).ignoresSafeArea()
            
            HStack{
                Spacer()
                VerticalSlider(value: $cameraHeight, range: sideView.cameraHeight...topView.cameraHeight)
                    .frame(width: 15, height: 300)
                    .padding()
                    .background(.clear)
            }
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_deco: UIViewRepresentable {
    @Binding var cameraHeight: Float
    
    // TODO: - 타이니 클래스에서 색상 불러오기
    var selectedColor:Color = .white
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        context.coordinator.cakeParentEntity = cakeParentEntity
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        // MARK: CakeSurface - TODO
        let cakeSurfaceModel = try! ModelEntity.loadModel(named: "cakeSurface")
        cakeSurfaceModel.scale = SIMD3(repeating: 0.43)
        
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        cakeAnchor.addChild(cakeSurfaceModel)
        arView.scene.anchors.append(cakeAnchor)
        
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

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // MARK: 슬라이더 연동 Camera 높이값 변동
        context.coordinator.camera?.position.y = cameraHeight
        context.coordinator.camera?.position.x = cameraHeight * 0.6
        context.coordinator.cakeParentEntity?.scale *= cameraHeight * 1.2
    }
    
    func makeCoordinator() -> Coordinator_deco {
        return Coordinator_deco()
    }
}

class Coordinator_deco: NSObject {
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    
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

//enum CameraMode {
//    case quarterView
//    case topDownView
//    
//    var angle: Double {
//        switch self {
//        case .quarterView:
//            return -45.0 * .pi / 180.0
//        case .topDownView:
//            return -90.0 * .pi / 180.0
//        }
//    }
//    
//    var position: SIMD3<Float> {
//        switch self {
//        case .quarterView:
//            return [0, 0.5, 0.5]
//        case .topDownView:
//            return [0, 0.65, 0]
//        }
//    }
//    
//    var defaultGestureMode: GestureMode {
//        switch self {
//        case .quarterView:
//            return .allGesture
//        case .topDownView:
//            return .onlyScaleGesture
//        }
//    }
//}


enum GestureMode {
    case onlyScaleGesture
    case allGesture
    
    var scale: [Double] {
        switch self {
        case .onlyScaleGesture:
            return [1.0, 2.0]
        case .allGesture:
            return [0.5, 3.0]
        }
    }
}


#Preview {
    //Cake3DDecoView()
    CakeDecorationView(value: 4, path: .constant([4]))
}
