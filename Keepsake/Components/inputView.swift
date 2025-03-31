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
        VStack {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size:14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size:14))
            }
            Divider()
        }
    }
}
