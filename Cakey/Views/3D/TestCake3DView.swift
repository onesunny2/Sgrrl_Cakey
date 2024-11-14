//
//  TestCake3DView.swift
//  Cakey
//
//  Created by dora on 11/13/24.
//

import SwiftUI
import ARKit
import RealityKit
import Combine


struct TestCake3DView: View {
    @State private var cameraHeight: Float = 0.5
    @StateObject private var coordinator = Coordinator2()
    
    var body: some View {
        ZStack{
            ARViewContainer2(cameraHeight: $cameraHeight, coordinator: coordinator).ignoresSafeArea()
            HStack{
                Spacer()
                VerticalSlider(value: $cameraHeight, range: 0.5...2.0)
                    .frame(width: 15, height: 300)
                    .padding()
                    .background(.clear)
            }
        }
            
            HStack{
                Button(action: {
                    coordinator.addDecoEntity(imgName: "zzamong")
                }) {
                    Image("zzamong")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color.teal)
                        .cornerRadius(10)
                }
                Button(action: {
                    coordinator.addDecoEntity(imgName: "zzamong")
                }) {
                    Image("zzamong")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color.teal)
                        .cornerRadius(10)
                }
                Button(action: {
                    coordinator.addDecoEntity(imgName: "zzamong")
                }) {
                    Image("zzamong")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color.teal)
                        .cornerRadius(10)
                }
            
        }
    }
}

struct ARViewContainer2: UIViewRepresentable {
    @Binding var cameraHeight: Float
    @ObservedObject var coordinator: Coordinator2
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        /// Deco 달아줄 Anchor
        let emptyAnchor = AnchorEntity(world: [0, 0, 0])
        coordinator.emptyAnchor = emptyAnchor
        arView.scene.addAnchor(emptyAnchor)
        
        let selectedMaterial = SimpleMaterial(color: .cakeyOrange1, isMetallic: false)
        let cakeParentEntity = ModelEntity()
        
        let selectedMaterial2 = SimpleMaterial(color: .white, isMetallic: false)
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let planeModel = try! ModelEntity.loadModel(named: "cakeSurface")
        planeModel.model?.materials = [selectedMaterial2]
        planeModel.scale = SIMD3(x: 0.4, y: 0.4, z: 0.4)
        
        emptyAnchor.addChild(planeModel)
        arView.scene.anchors.append(emptyAnchor)
        
        /// Cake model
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(x: 0.4, y: 0.4, z: 0.4)
        cakeModel.model?.materials = [selectedMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(x: 0.4, y: 0.4, z: 0.4)
        
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        cakeParentEntity.addChild(emptyAnchor)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        
        let anchor = AnchorEntity(world: [0, 0, 0])
        anchor.addChild(cakeParentEntity)
        arView.scene.anchors.append(anchor)
        
        context.coordinator.cakeParentEntity = cakeParentEntity
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        /// Camera setup
        let camera = PerspectiveCamera()
        camera.position = [0, cameraHeight, 1]
        
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        context.coordinator.camera = camera
        
        context.coordinator.cancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            camera.look(at: cakeParentEntity.position, from: camera.position, relativeTo: nil)
            context.coordinator.clampModelSize()
        } as? AnyCancellable
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.camera?.position.y = cameraHeight
        context.coordinator.camera?.position.x = cameraHeight * 0.6
        
        let selectedMaterial = SimpleMaterial(color: .cakeyOrange1, isMetallic: false)
        context.coordinator.cakeEntity?.model?.materials = [selectedMaterial]
    }
    
    func makeCoordinator() -> Coordinator2 {
        return Coordinator()
    }
}

class Coordinator2: NSObject, ObservableObject {
    
    var arView: ARView?
    var emptyAnchor: AnchorEntity?
    
    var cakeParentEntity: ModelEntity?
    var cakeEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    
    func addDecoEntity(imgName: String) {
        guard !imgName.isEmpty, let arView = arView else { return }

        let planeMesh = MeshResource.generatePlane(width: 1, height: 1)
        let plane = ModelEntity(mesh: planeMesh)

        if let texture = try? TextureResource.load(named: imgName) {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            material.opacityThreshold = 0.1
            plane.model?.materials = [material]
        }

        plane.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: plane)

        emptyAnchor?.addChild(plane)
    }
    
    func clampModelSize() {
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
    TestCake3DView()
}

