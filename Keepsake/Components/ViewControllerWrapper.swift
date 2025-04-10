//
//  ViewControllerWrapper.swift
//  Keepsake
//
//  Created by Nitya Potti on 4/6/25.
//

import SwiftUI
import UIKit
//This is for the notifications and I added this in content view otherwise the notifications were not being dispatched
struct ViewControllerWrapper: UIViewControllerRepresentable {
    var aiViewModel: AIViewModel
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
       //need this to conform
    }
}
