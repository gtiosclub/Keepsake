//
//  AIImageView.swift
//  Keepsake
//
//  Created by Muhammad Hamd Azam on 2/8/25.
//

import SwiftUI

struct AIImageView: View {
    @StateObject private var viewModel = AIViewModel()
    
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    var body: some View {
        VStack {
            if let uiImage = viewModel.uiImage {
                Image(uiImage: uiImage).resizable().scaledToFit().frame(maxWidth:.infinity, maxHeight: 300).padding()
            } else if viewModel.isLoading {
                ProgressView("Loading image...")
            } else {
                Text("No image loaded")
            }
            
            Button("Generate Image") {
                Task {
                    await viewModel.generateImage(for: JournalEntry(date: "01/01/2025", title: "Sunshines", text: "Rainbows"))
                }
            }
        }.padding()
    }
}

#Preview {
    AIImageView()
}
