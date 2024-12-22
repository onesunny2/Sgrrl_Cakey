//
//  Cake3DFinalView.swift
//  Cakey
//
//  Created by dora on 12/3/24.
//

import SwiftUI
import ARKit
import RealityKit

struct Cake3DFinalView: View {
//    var viewModel: CakeyViewModel
    var cakeyModel: CakeyModel
    
    var body: some View {
        ARViewContainer_Final(cakeyModel: cakeyModel)
            .ignoresSafeArea()
    }
}

struct ARVariables{
  static var arView: ARView!
}

struct ARViewContainer_Final:UIViewRepresentable {
//    var viewModel: CakeyViewModel
    var cakeyModel: CakeyModel
    var quaterView: CameraMode = CameraMode.quarterView
    
    func makeUIView(context: Context) -> some UIView {
        // MARK: ARView 초기화
        ARVariables.arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        ARVariables.arView.environment.background = .color(.cakeyYellow1)
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        
        let selectedColor = Color(hex:cakeyModel.cakeColor!)
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)

        cakeParentEntity.generateCollisionShapes(recursive: true)
        context.coordinator.cakeParentEntity = cakeParentEntity
        context.coordinator.loadDecoEntity()
        context.coordinator.addTextEntity()
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        ARVariables.arView.scene.anchors.append(cakeAnchor)

        // MARK: Virtual Camera
        let camera = PerspectiveCamera()
        camera.position = [0, quaterView.cameraHeight, 1]
        camera.look(at: cakeParentEntity.position, from: camera.position, relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        ARVariables.arView.scene.addAnchor(cameraAnchor)
        
        return ARVariables.arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator_final {
        return Coordinator_final()
    }
}

class Coordinator_final: NSObject {
    var cakeParentEntity: ModelEntity?
    //var decoEntities = CakeState.shared
    var cakeManager = CakeStateManager.shared
    
    func loadDecoEntity() {
        guard let topStack = cakeManager.cakeStack.top() else {return }
        
        // DecoEntity 데이터 순회
        for deco in topStack.decoEntities {
            let imgData = deco.image
            let pos = deco.position
            let scale = deco.scale
            let orientation = deco.orientation
            
            addDecoEntity(imgData: imgData, position: pos, scale: scale, orientation: orientation)
        }
        
        // TODO: 확인, TextENtity도 추가
        
        addTextEntity()
    }
    
    func addDecoEntity(imgData: Data, position: SIMD3<Float>, scale: SIMD3<Float>, orientation: simd_quatf) {
        
        guard let cakeParentEntity = cakeParentEntity else { return }
        
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
                print("텍스처 생성 실패: \(error.localizedDescription)")
            }
        }
        
        // 위치 조정
        plane.position = position
        plane.scale = scale
        plane.orientation = orientation
        
        // 부모 엔티티에 추가
        cakeParentEntity.addChild(plane)
    }
    
    func addTextEntity() {
        guard let topStack = cakeManager.cakeStack.top() else { return }
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        // 저장된 텍스트 엔티티 데이터 로드
        let textData = topStack.textEntity
        
        // 텍스트가 비어있는지 확인
        let text = textData.text
        
        // 텍스트 메시 생성
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        // 텍스트 색상 적용
        let textMaterial = SimpleMaterial(color: UIColor(textData.color), isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.transform.rotation = simd_quatf(angle: Float.pi * 1.5, axis: [1, 0, 0])
        textEntity.scale = textData.scale // 저장된 스케일 적용
        textEntity.position = textData.position // 저장된 위치 적용
        textEntity.position.z += 0.3
        textEntity.position.y -= 0.09
        textEntity.scale *= 1.2
        
        // 부모 엔티티에 추가
        cakeParentEntity.addChild(textEntity)
        print("텍스트 엔티티 추가 완료. 텍스트: \(text), 위치: \(textEntity.position), 스케일: \(textEntity.scale)")
    }
}
