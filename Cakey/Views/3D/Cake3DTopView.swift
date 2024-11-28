//
//  CakeTopView.swift
//  Cakey
//
//  Created by dora on 11/26/24.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: - CakeLetteringView에 들어갈 3D
struct Cake3DTopView: View {
    //var viewModel: CakeyViewModel
    
    var body: some View {
        ZStack {
            //ARViewContainer_top(selectedColor: Color(hex: viewModel.cakeyModel.cakeColor!))
                //.ignoresSafeArea()
            ARViewContainer_top(selectedColor: Color(hex: "000000"))
                .ignoresSafeArea()
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_top: UIViewRepresentable {
    var selectedColor: Color
    var topView: CameraMode = CameraMode.topView
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.7)
        let defaultMaterial = SimpleMaterial(color: .white, isMetallic: false)
        cakeModel.model?.materials = [defaultMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.7)
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)

        cakeParentEntity.generateCollisionShapes(recursive: true)
        context.coordinator.cakeParentEntity = cakeParentEntity
        // FIXME: ColorView에서 제스처 필요없어 보임
        //arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        arView.scene.anchors.append(cakeAnchor)

        // MARK: Virtual Camera
        let camera = PerspectiveCamera()
        camera.position = [0, topView.cameraHeight, 0]
        camera.look(at: cakeParentEntity.position, from: camera.position, relativeTo: nil)
        context.coordinator.camera = camera
        
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // MARK: - selectedColor 변경 시 호출
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        context.coordinator.cakeEntity?.model?.materials = [selectedMaterial]
    }
    
    func makeCoordinator() -> Coordinator_top {
        return Coordinator_top()
    }
}

// MARK: - Coordinator
class Coordinator_top: NSObject {
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
}

#Preview {
    Cake3DTopView()
}
