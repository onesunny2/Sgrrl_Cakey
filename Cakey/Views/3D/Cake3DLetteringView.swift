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
    
    var body: some View {
        ZStack {
            //ARViewContainer_top(selectedColor: Color(hex: viewModel.cakeyModel.cakeColor!))
                //.ignoresSafeArea()
            ARViewContainer_top(viewModel: viewModel)
                .ignoresSafeArea()
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer_top: UIViewRepresentable {
    var topView: CameraMode = CameraMode.topView
    var viewModel: CakeyViewModel
    
    func makeUIView(context: Context) -> ARView {
        // MARK: ARView 초기화
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.clear)
        
        // TODO: 저장된 CakeEntity로 바꾸기!
        
        // MARK: CakeModel
        let cakeModel = try! ModelEntity.loadModel(named: "cakeModel")
        cakeModel.scale = SIMD3(repeating: 0.7)
        
        let selectedColor = Color(hex:viewModel.cakeyModel.cakeColor!)  // 선택 컬러 적용
        let selectedMaterial = SimpleMaterial(color: UIColor(selectedColor), isMetallic: false)
        
        let defaultMaterial = SimpleMaterial(color: .white, isMetallic: false)
        cakeModel.model?.materials = [selectedMaterial]
        context.coordinator.cakeEntity = cakeModel
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.7)
        
        let decoAnchor = AnchorEntity()
        context.coordinator.decoAnchor = decoAnchor
        context.coordinator.loadDecoEntities()
        // MARK: 추가함
//        let textMesh = MeshResource.generateText(viewModel.cakeyModel.letteringText ?? "생일축하해", extrusionDepth: 0.01, font: UIFont(name: "Hakgyoansim Dunggeunmiso OTF B", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15), containerFrame: .zero, alignment: .left, lineBreakMode: .byTruncatingHead)
//                let textMaterial = SimpleMaterial(color: .black, isMetallic: true)
//               
//        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
//        let rotationAngle = Float.pi * 1.5 // 180도 (라디안)
//        textEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: [1, 0, 0])
//        textEntity.position.y += (0.79 * 0.43 + 0.02 )/0.43 * 0.7
//        
//        
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        //cakeParentEntity.addChild(textEntity)

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
    }
    
    func makeCoordinator() -> Coordinator_top {
        return Coordinator_top(viewModel: viewModel)
    }
}

// MARK: - Coordinator
class Coordinator_top: NSObject {
    var cakeEntity: ModelEntity?
    var cakeParentEntity: ModelEntity?
    var decoAnchor: AnchorEntity?
    var camera: PerspectiveCamera?
    var viewModel: CakeyViewModel?
    
    // MARK: viewModel 초기화
    init(viewModel: CakeyViewModel) {
            self.viewModel = viewModel
        }
    
    // MARK: 저장된 decoEntity 불러오기
    func loadDecoEntities() {
        print("loadDecoEntities함수 실행!")
        guard let decoAnchor = decoAnchor else { return }

        // Realm에서 가장 마지막 CakeyModel 읽기
        guard let savedCakeyModel = viewModel?.readDeco() else {
            print("저장된 CakeyModel을 찾을 수 없습니다.")
            return
        }

        // DecoEntity를 순회하면서 AR 씬에 추가
        for deco in savedCakeyModel.decoEntities {
            // DecoEntity의 image 이름과 viewModel의 cakeImages를 비교하여 매칭된 데이터 가져오기
            guard let decoImageName = deco.image,
                  let matchedImageData = viewModel?.cakeyModel.cakeImages.first(where: { $0.image == decoImageName })?.image,
                  let uiImage = UIImage(data: matchedImageData),
                  let cgImage = uiImage.cgImage else {
                print("이미지를 불러오는데 실패했습니다.")
                continue
            }

            do {
                // 텍스처 생성
                let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                var material = UnlitMaterial()
                material.color = .init(tint: .white, texture: .init(texture))
                material.opacityThreshold = 0.1

                // 평면 메쉬 생성
                let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
                let plane = ModelEntity(mesh: planeMesh, materials: [material])

                // 저장된 위치와 크기 적용
                if let position = deco.position {
                    plane.position = position
                } else {
                    plane.position.y += 0.79 * 0.43 + 0.02  // 기본 위치
                }
                if let scale = deco.transform?.scale {
                    plane.scale = scale
                } else {
                    plane.scale /= 2  // 기본 스케일
                }
                if let rotation = deco.transform?.rotation {
                    plane.orientation = rotation
                }

                // decoAnchor에 추가
                decoAnchor.addChild(plane)
            } catch {
                print("텍스처 생성 실패: \(error.localizedDescription)")
            }
        }
    }



}

//#Preview {
//    Cake3DTopView()
//}
