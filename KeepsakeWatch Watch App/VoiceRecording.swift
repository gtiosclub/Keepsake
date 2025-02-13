//
//  VoiceRecording.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/10/25.
//

import Foundation
import SwiftUI

struct WatchFaceView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Black background like watchOS faces
            
            VStack(spacing: 8) {
                Text("Recording")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Circle()
                    .fill(Color.red)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
        }
    }
}

struct WatchFaceView_Previews: PreviewProvider {
    static var previews: some View {
        WatchFaceView()
    }
}
