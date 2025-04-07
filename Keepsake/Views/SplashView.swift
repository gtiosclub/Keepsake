//
//  SplashView.swift
//  Keepsake
//
//  Created by Shlok Patel on 4/7/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            isLoggedInView() // your existing root router
        } else {
            VStack {
                Text("Keepsake")
                    .font(.system(size: 60, weight: .semibold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
