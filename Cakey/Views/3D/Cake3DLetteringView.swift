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

// 🪵 BackLogs
//TODO: 중앙 정렬 계산식 정리 필요!

// MARK: - CakeLetteringView에 들어갈 3D
struct Cake3DLetteringView: View {
    var viewModel: CakeyViewModel
    @Binding var text: String
    @Binding var selectedColor: Color
    
    var coordinator_top : Coordinator_top
    
    var body: some View {
        
        ARViewContainer_top(coordinator_top: coordinator_top, viewModel: viewModel, text: $text, selectedColor: $selectedColor)
                .ignoresSafeArea()
                .frame(height: 250)
        
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_top: UIViewRepresentable {
    @ObservedObject var coordinator_top: Coordinator_top
    var topView: CameraMode = CameraMode.quarterView
    var viewModel: CakeyViewModel
    @Binding var text: String
    @Binding var selectedColor: Color
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.43)
        
        let selectedColor = Color(hex:viewModel.cakeyModel.cakeColor!)
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        
        cakeModel.model?.materials = [selectedMaterial]
        coordinator_top.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        // MARK: CakeParent
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        coordinator_top.cakeParentEntity = cakeParentEntity
        coordinator_top.arView = arView
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        arView.scene.anchors.append(cakeAnchor)
        
        // MARK: Virtual Camera
        let camera = PerspectiveCamera()
        camera.position = [0, topView.cameraHeight + 0.25, 0]
        camera.look(at: cakeParentEntity.position, from: camera.position, relativeTo: nil)
        context.coordinator.camera = camera
        
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // MARK: 저장된 데코 불러오기
        coordinator_top.loadDecoEntity()
        // MARK: 레터링 색상 적용
        coordinator_top.selectedColor = selectedColor
        // MARK: 텍스트 입력에 따른 모델 업데이트
        coordinator_top.updateTextEntity(text)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        coordinator_top.updateTextEntity(text)
        coordinator_top.selectedColor = selectedColor
        coordinator_top.updateTextColor()
    }
    
    func makeCoordinator() -> Coordinator_top {
        return Coordinator_top()
    }
}

// MARK: - Coordinator
class Coordinator_top: NSObject, ObservableObject {
    var arView: ARView?
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var textEntity: ModelEntity?
    var selectedColor: Color?
    
    //var decoEntities = CakeState.shared
    
    func updateTextEntity(_ newText: String) {
        guard let cakeParentEntity = cakeParentEntity else { return }
        
        // MARK: 기존 텍스트 엔티티 삭제
        if let existingTextEntity = textEntity {
            cakeParentEntity.removeChild(existingTextEntity)
        }
        
        // MARK: 텍스트를 줄 단위로 분리
        let lines = newText.split(separator: "\n")
        // 가장 긴 줄의 글자 수
        let maxCharsInLine = lines.map { $0.count }.max() ?? 0
        // 총 줄 수
        let totalLines = lines.count
        // 한 글자 너비
        let charWidth: Float = 0.13874995
        // 한 글자 높이
        let lineHeight: Float = 0.13470002
        
        
        // MARK: 텍스트에 따라 위치 계산
        let xPosition: Float = -charWidth * Float(maxCharsInLine) / 4.0
        let zPosition: Float = lineHeight * Float(totalLines - 1) / 2.0
        
        // MARK: 새로운 텍스트 엔티티 생성
        let textMesh = MeshResource.generateText(
            newText,
            extrusionDepth: 0.01,
            font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let textMaterial = SimpleMaterial(color: UIColor(selectedColor ?? .black), isMetallic: false)
        let newTextEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        newTextEntity.transform.rotation = simd_quatf(angle: Float.pi * 1.5, axis: [1, 0, 0])
        newTextEntity.scale = newTextEntity.scale / 2
        
        // MARK: 텍스트 위치 설정
        newTextEntity.position.x = xPosition
        newTextEntity.position.z = zPosition
        let baseYPosition: Float = (0.79 * 0.43 + 0.02) / 0.43 * 0.7
        newTextEntity.position.y = baseYPosition

        // MARK: 추가
        print("현재 text는 \(newText)고, x=\(xPosition), z=\(zPosition), 너비=\(textMesh.bounds.max.x - textMesh.bounds.min.x), 높이=\(textMesh.bounds.max.y - textMesh.bounds.min.y)")
        cakeParentEntity.addChild(newTextEntity)
        
        textEntity = newTextEntity
        
    }

    
    //MARK: 텍스트 모델 컬러 변경
    func updateTextColor() {
        guard let textEntity = textEntity else { return }
        let textMaterial = SimpleMaterial(color: UIColor(selectedColor ?? .black), isMetallic: false)
        textEntity.model?.materials = [textMaterial]
    }
    
    //MARK: 데코 불러오기
    func loadDecoEntity() {
        guard let topState = CakeStateManager.shared.cakeStack.top() else { return }
        print("3DDecoView - loadDecoEntity")
        
        if(!topState.decoEntities.isEmpty){
            print("현재 스택에 이미 저장된 decoEntity가 있어서 불러오겠다!")
            for deco in topState.decoEntities {
                let imgData = deco.image
                let pos = deco.position
                let scale = deco.scale
                let orientation = deco.orientation
                
                addDecoEntity(imgData: imgData, position: pos, scale: scale, orientation: orientation)
            }
        }else{
            print("현재 스택에 decoEntity가 따로 없다!")
        }
        
    }
    
    // MARK: 데코 추가
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
        
        plane.position = position
        plane.scale = scale
        plane.orientation = orientation
        
        cakeParentEntity.addChild(plane)
    }
    
    //TODO: 텍스트 모델 저장
    // 이거 시점 고치기!
    func saveTextEntity(){
        guard let topStack = CakeStateManager.shared.cakeStack.top() else {return }
        
        topStack.textEntity.color = selectedColor ?? Color.black
        topStack.textEntity.position = textEntity?.position(relativeTo: nil) ?? SIMD3<Float>()
        topStack.textEntity.scale = textEntity?.scale(relativeTo: nil) ?? SIMD3<Float>()
    }
}


