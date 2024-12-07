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
struct Cake3DLetteringView: View {
    var viewModel: CakeyViewModel
    @Binding var text: String
    
    var body: some View {
        ZStack {
            ARViewContainer_top(viewModel: viewModel, text: $text)
                .ignoresSafeArea()
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_top: UIViewRepresentable {
    //var topView: CameraMode = CameraMode.topView
    var topView: CameraMode = CameraMode.quarterView
    var viewModel: CakeyViewModel
    @Binding var text: String
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // TODO: 저장된 CakeEntity로 바꾸기!
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        
        let selectedColor = Color(hex:viewModel.cakeyModel.cakeColor!)  // 선택 컬러 적용
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        
        cakeModel.model?.materials = [selectedMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        let decoAnchor = AnchorEntity()
        context.coordinator.decoAnchor = decoAnchor
        
        
        // MARK: 추가함
//                let textMesh = MeshResource.generateText(viewModel.cakeyModel.letteringText ?? "생일축하해", extrusionDepth: 0.01, font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15), containerFrame: .zero, alignment: .left, lineBreakMode: .byTruncatingHead)
//                        let textMaterial = SimpleMaterial(color: .black, isMetallic: true)
//        
//                let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
//                let rotationAngle = Float.pi * 1.5 // 180도 (라디안)
//                textEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: [1, 0, 0])
//                textEntity.position.y += (0.79 * 0.43 + 0.02 )/0.43 * 0.7
//        
        
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        //cakeParentEntity.addChild(textEntity)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        context.coordinator.cakeParentEntity = cakeParentEntity
        // FIXME: ColorView에서 제스처 필요없어 보임
        //arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        context.coordinator.arView = arView
        
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
        
        context.coordinator.loadDecoEntity()
        context.coordinator.updateTextEntity(text)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.updateTextEntity(text)
    }
    
    func makeCoordinator() -> Coordinator_top {
        return Coordinator_top()
    }
}

// MARK: - Coordinator
class Coordinator_top: NSObject {
    var arView: ARView?
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var decoAnchor: AnchorEntity?
    var camera: PerspectiveCamera?
    var textEntity: ModelEntity?

    var decoEntities = DecoEntities.shared
    
    func updateTextEntity(_ newText: String) {
            guard let cakeParentEntity = cakeParentEntity else { return }
            
            // 기존 텍스트 엔티티 삭제
            if let existingTextEntity = textEntity {
                cakeParentEntity.removeChild(existingTextEntity)
            }
            
            // 새로운 텍스트 엔티티 생성
            let textMesh = MeshResource.generateText(
                newText,
                extrusionDepth: 0.01,
                font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
            
            let textMaterial = SimpleMaterial(color: .black, isMetallic: true)
            let newTextEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
            newTextEntity.transform.rotation = simd_quatf(angle: Float.pi * 1.5, axis: [1, 0, 0])
        newTextEntity.scale = newTextEntity.scale/2.5
            newTextEntity.position.y += (0.79 * 0.43 + 0.02) / 0.43 * 0.7
            newTextEntity.position.x -= 0.15
            
            // 부모 엔티티에 추가
            cakeParentEntity.addChild(newTextEntity)
            textEntity = newTextEntity
        }

    
    func loadDecoEntity() {
        print("Lettering - loadDeco 실행!")
        print("저장된 데코엔티티 개수: \(decoEntities.decoEntities.count)")
        
        // DecoEntity 데이터 순회
        for deco in decoEntities.decoEntities {
            let imgData = deco.image
            let pos = deco.position
            let scale = deco.scale
            let orientation = deco.orientation
            
            addDecoEntity(imgData: imgData, position: pos, scale: scale, orientation: orientation)
        }
    }
    
    func addDecoEntity(imgData: Data, position: SIMD3<Float>, scale: SIMD3<Float>, orientation: simd_quatf) {
        
        print("Lettering - addDeco 실행!")
        print("레터링뷰에서의 imgData: \(imgData)")
        print("레터링뷰에서의 position: \(position)")
        print("레터링뷰에서의 scale: \(scale)")
        print("레터링뷰에서의 orientation: \(orientation)")
        
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
        print("cakedeco 개수는\(cakeParentEntity.children.count)")
    }
    
}

