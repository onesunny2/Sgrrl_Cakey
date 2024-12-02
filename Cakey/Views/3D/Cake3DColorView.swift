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

// MARK: - CakeColorView에 들어갈 3D
struct Cake3DColorView: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        ZStack {
            ARViewContainer_color(selectedColor: $selectedColor)
                .ignoresSafeArea()
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_color: UIViewRepresentable {
    @Binding var selectedColor: Color
    var quaterView: CameraMode = CameraMode.quarterView
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        let defaultMaterial = SimpleMaterial(color: .white, isMetallic: false)
        cakeModel.model?.materials = [defaultMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)

        cakeParentEntity.generateCollisionShapes(recursive: true)
        context.coordinator.cakeParentEntity = cakeParentEntity
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        arView.scene.anchors.append(cakeAnchor)

        // MARK: Virtual Camera
        let camera = PerspectiveCamera()
        camera.position = [0, quaterView.cameraHeight, 1]
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
    
    func makeCoordinator() -> Coordinator_color {
        return Coordinator_color()
    }
}

// MARK: - Coordinator
class Coordinator_color: NSObject {
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
}

//#Preview {
//    CakeColorView(value: 1, path: .constant([1]))
//}

