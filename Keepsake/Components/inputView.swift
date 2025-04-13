//
//  inputView.swift
//  Keepsake
//
//  Created by Nitya Potti on 3/18/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title text
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)

            // TextField or SecureField
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .frame(height: 50)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .frame(height: 50)
            }
        }
        .padding(.horizontal, 4)
    }
}
