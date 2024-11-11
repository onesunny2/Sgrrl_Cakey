//
//  TestView.swift
//  Cakey
//
//  Created by dora on 11/10/24.
//

import SwiftUI

struct TestView: View {
    @State private var cameraMode: CameraMode = .topDownView
    
    var body: some View {
        Cake3DView()
            .frame(maxWidth: 380, maxHeight: 380)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        
        HStack{
            Button(action: {
                cameraMode = .topDownView
                print("Button tapped!")
            }) {
                Text("TopDown")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Button(action: {
                cameraMode = .quarterView
                print("Quater")
            }) {
                Text("Quater")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    TestView()
}
