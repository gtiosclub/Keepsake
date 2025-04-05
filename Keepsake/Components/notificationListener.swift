//
//  notificationListener.swift
//  Keepsake
//
//  Created by Nitya Potti on 4/5/25.
//


import SwiftUI
import UserNotifications

struct NotificationView: View {
    @State private var notificationTitle = ""
    @State private var notificationBody = ""

    var body: some View {
        VStack {
            Text(notificationTitle)
                .font(.headline)
                .padding()
            
            Text(notificationBody)
                .padding()
            
            Button("Dismiss") {
            }
        }
        .onAppear {
        }
    }
    func updateNotification(_ notification: UNNotification) {
        notificationTitle = notification.request.content.title
        notificationBody = notification.request.content.body
    }
}
