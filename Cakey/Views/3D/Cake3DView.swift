//
//  Cake3DView.swift
//  Cakey
//
//  Created by dora on 11/7/24.
//

import SwiftUI
import ARKit
import RealityKit

struct Cake3DView: View {
    var cameraMode: CameraMode
    
    var body: some View {
        ARViewContainer(cameraMode: cameraMode).ignoresSafeArea()
    }
}

struct ARViewContainer: UIViewRepresentable {
    var cameraMode: CameraMode
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        //arView.environment.background = .color(.clear)
        arView.environment.background = .color(.black)
        
        let selectedMaterial = SimpleMaterial(color: .cakeyOrange1, isMetallic: false)
        
        let cakeParentEntity = ModelEntity()
        
        /// Cake model
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(x: 0.4, y: 0.4, z: 0.4)
        //cakeModel.generateCollisionShapes(recursive: true)
        cakeModel.model?.materials = [selectedMaterial]
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(x: 0.4, y: 0.4, z: 0.4)
        //cakeTrayModel.generateCollisionShapes(recursive: true)
        
        
        
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        cakeParentEntity.generateCollisionShapes(recursive: true)
        
        let anchor = AnchorEntity(world: [0, 0, 0])
        //anchor.addChild(cakeModel)
        //anchor.addChild(cakeTrayModel)
        anchor.addChild(cakeParentEntity)
        arView.scene.anchors.append(anchor)
        
        //cakeParentEntity.generateCollisionShapes(recursive: true)
        
        //arView.installGestures(.all, for: cakeModel)
        arView.installGestures(.all, for: cakeParentEntity)
        
        
        /// Camera setup
        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world: cameraMode.position)
        
        let angle = cameraMode.angle
        camera.transform.rotation = simd_quatf(angle: Float(angle), axis: [1, 0, 0])
        
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // Set up the coordinator’s camera anchor reference
        context.coordinator.cameraAnchor = cameraAnchor
        
       
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let cameraAnchor = context.coordinator.cameraAnchor else { return }
        
        // Update camera position and rotation based on `cameraMode`
        cameraAnchor.position = cameraMode.position
        let angle = Float(cameraMode.angle)
        
        if let camera = cameraAnchor.children.first as? PerspectiveCamera {
            camera.transform.rotation = simd_quatf(angle: angle, axis: [1, 0, 0])
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

class Coordinator: NSObject {
    var cameraAnchor: AnchorEntity?
}

enum CameraMode {
    case quarterView
    case topDownView
    
    var angle: Double {
        switch self {
        case .quarterView:
            return -45.0 * .pi / 180.0
        case .topDownView:
            return -90.0 * .pi / 180.0
        }
    }
    
    var position: SIMD3<Float> {
        switch self {
        case .quarterView:
            return [0, 0.5, 0.5]
        case .topDownView:
            return [0, 0.65, 0]
        }
    }
    
    var defaultGestureMode: GestureMode {
        switch self {
        case .quarterView:
            return .allGesture
        case .topDownView:
            return .onlyScaleGesture
        }
    }
}


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
    
    var rotation: [simd_float3] {
        switch self {
        case .onlyScaleGesture:
            return [simd_float3(-45, -45, -45), simd_float3(45, 45, 45)]
        case .allGesture:
            return [simd_float3(-90, -90, -90), simd_float3(90, 90, 90)]
        }
    }
}


#Preview {
    Cake3DView(cameraMode: .quarterView)
}
