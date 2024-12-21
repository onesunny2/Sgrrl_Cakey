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
        
        // MARK: updateUI에서 감지 못하는 SceneEvent 구독
        coordinator_top.cancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in

            coordinator_top.clampTextPosition()
        } as? AnyCancellable
        
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
    var cancellable: AnyCancellable?
    
    //var decoEntities = CakeState.shared
    
    func updateTextEntity(_ newText: String) {
        guard let cakeParentEntity = cakeParentEntity else { return }

        // MARK: 기존 텍스트 엔티티 삭제
        if let existingTextEntity = textEntity {
            cakeParentEntity.removeChild(existingTextEntity)
        }

        // MARK: 텍스트를 줄 단위로 분리
        let lines = newText.split(separator: "\n")
        let totalLines = lines.count // 총 줄 수

        // 한글 : 한 글자 너비 및 높이
        let charWidth: Float = 0.13874995
        let lineHeight: Float = 0.13470002
        // 영어 : 한 글자 너비
        let engCharWidth: Float = 0.09705

        // MARK: 각 줄의 최대 너비 계산
        var maxWidth: Float = 0.0
        for line in lines {
            var lineWidth: Float = 0.0
            for char in line {
                if char.isASCII {
                    lineWidth += engCharWidth // 영어
                } else {
                    lineWidth += charWidth // 한글
                }
            }
            maxWidth = max(maxWidth, lineWidth)
        }

        // MARK: 텍스트의 위치 계산
        let xPosition: Float = -maxWidth / 4.0
        let zPosition: Float = lineHeight * Float(totalLines - 1) / 2.0

        // MARK: 새로운 텍스트 엔티티 생성
        let textMesh = MeshResource.generateText(
            newText,
            extrusionDepth: 0.01,
            font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15, weight: .bold),
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


        // MARK: 부모 엔티티에 추가
        print("현재 text는 \(newText)고, x=\(xPosition), z=\(zPosition), 너비=\(maxWidth), 높이=\(lineHeight * Float(totalLines))")
        
        newTextEntity.generateCollisionShapes(recursive: true)
        cakeParentEntity.addChild(newTextEntity)
        arView?.installGestures([.translation], for: newTextEntity)

        textEntity = newTextEntity
    }

    func clampTextPosition() {
        guard let textEntity = textEntity else { return }

        let radius: Float = 0.3 // 원의 반지름
        let centerOffset: SIMD3<Float> = SIMD3(-0.05, -0.02, 0) // 새로운 원의 중점 (x: -0.05, z: 0)
        var position = textEntity.position(relativeTo: nil)
        
        // 원의 새로운 중심과 현재 위치 간의 거리 계산
        let adjustedPosition = position - centerOffset
        let distanceSquared = adjustedPosition.x * adjustedPosition.x + adjustedPosition.z * adjustedPosition.z

        // 원 밖으로 나갔을 경우 위치 제한
        if distanceSquared > radius * radius {
            print("clampTextPosition: 텍스트가 원 밖으로 벗어남. 위치 조정 중...")
            let distance = sqrt(distanceSquared)
            let clampedX = adjustedPosition.x * (radius / distance)
            let clampedZ = adjustedPosition.z * (radius / distance)

            // 원의 중심을 기준으로 위치를 보정한 후 원래 좌표계로 되돌림
            position.x = clampedX + centerOffset.x
            position.z = clampedZ + centerOffset.z
            textEntity.position = position
        }
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


