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
    @StateObject private var coordinator_deco = Coordinator_deco()
    
    @State private var cameraHeight: Float = 0.8
    var topView: CameraMode = CameraMode.topView
    var sideView: CameraMode = CameraMode.sideView
    var imgList: [String] = ["p1"]
    
    var body: some View {
        ZStack{
            ARViewContainer_deco(cameraHeight: $cameraHeight).ignoresSafeArea()
            
            HStack{
                Spacer()
                VerticalSlider(value: $cameraHeight, range: sideView.cameraHeight...topView.cameraHeight)
                    .frame(width: 30, height: 300)
                    .padding()
                    .background(.clear)
            }
        }
        
        VStack {
            HStack(spacing: 30) {
                DecoActionCell(buttonColor: .cakeyOrange3, symbolName: "arrow.trianglehead.2.clockwise.rotate.90", buttonAction: { })
                DecoActionCell(buttonColor: .cakeyOrange1, symbolName: "trash",buttonText: "선택 삭제", buttonAction: { })
            } .padding(.bottom, 40)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        if index < imgList.count {
                            let img = imgList[index]
                            Button(action: {
                                coordinator_deco.addDecoEntity(imgName: img)
                                print("버튼 눌렀다!")
                            }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.clear)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        ZStack {
                                            Image("\(img)")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.cakeyOrange1, lineWidth: 2)
                                                .padding(1)
                                        }
                                    }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.cakeyOrange2)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.symbolTitle2)
                                        .foregroundStyle(.cakeyOrange3)
                                }
                        }
                    }

                }
            } .padding(.leading, (UIScreen.main.bounds.width - 292) / 2)
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
        
        let cakeTrayModel = try! ModelEntity.loadModel(named: "cakeTray")
        cakeTrayModel.scale = SIMD3(repeating: 0.43)
        
        let cakeParentEntity = ModelEntity()
        cakeParentEntity.addChild(cakeModel)
        cakeParentEntity.addChild(cakeTrayModel)
        
        cakeParentEntity.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.rotation, .scale], for: cakeParentEntity)
        
        // MARK: TODO: CakeSurface
        let cakeSurfaceModel = try! ModelEntity.loadModel(named: "cakeSurface")
        cakeSurfaceModel.scale = SIMD3(repeating: 0.43)
        let cakeWholeEntity = ModelEntity()
        
        // TEST
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let planeMaterial = SimpleMaterial(color: .pickerBlue, isMetallic: true)
        let planeModel = ModelEntity(mesh: planeMesh, materials:[planeMaterial])
        planeModel.position.y += 0.79 * 0.43    // 높이
        cakeParentEntity.addChild(planeModel)
        
        cakeWholeEntity.addChild(cakeParentEntity)
        cakeWholeEntity.addChild(cakeSurfaceModel)
        context.coordinator.cakeWholeEntity = cakeWholeEntity
        
        let cakeAnchor = AnchorEntity(world: [0, 0, 0])
        cakeAnchor.addChild(cakeParentEntity)
        cakeAnchor.addChild(cakeSurfaceModel)
        //arView.scene.anchors.append(cakeAnchor)
        arView.scene.addAnchor(cakeAnchor)
        
        //test
        context.coordinator.emptyAnchor = cakeAnchor
        
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
        //context.coordinator.cakeParentEntity?.scale *= cameraHeight * 1.2
    }
    
    func makeCoordinator() -> Coordinator_deco {
        return Coordinator_deco()
    }
}

class Coordinator_deco: NSObject, ObservableObject {
    var arView: ARView?
    var emptyAnchor:  AnchorEntity?
    var cakeWholeEntity: ModelEntity?
    var camera: PerspectiveCamera?
    var cancellable: AnyCancellable?
    
    // MARK: 데코 추가
    func addDecoEntity(imgName: String) {
        guard !imgName.isEmpty, let arView = arView else { return }

        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
        let plane = ModelEntity(mesh: planeMesh)
        plane.position.y += 0.79 * 0.45

        if let texture = try? TextureResource.load(named: imgName) {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            //material.opacityThreshold = 0.1
            plane.model?.materials = [material]
        }

        plane.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: plane)

        emptyAnchor?.addChild(plane)
        print("앵커의 수는 + \(arView.scene.anchors.count)")
        print("addDecoEntity")
    }

    
    // MARK: 모델 사이즈 Clamp
    func clampCakeSize() {
        guard let model = cakeWholeEntity else { return }
        
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
    //Cake3DDecoView()
    CakeDecorationView(value: 4, path: .constant([4]))
}
