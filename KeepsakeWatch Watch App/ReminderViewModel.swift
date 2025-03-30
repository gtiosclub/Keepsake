//
//  ReminderViewModel.swift
//  KeepsakeWatchOS Watch App
//
//  Created by Nitya Potti on 3/29/25.
//

import Combine
import SwiftUI
import AVFoundation

final class RemindersViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        Connectivity.shared.$reminders
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .assign(to: &$reminders)

        #if os(iOS)
        Connectivity.shared.fetchAudioFiles()
        #endif
    }

    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        Connectivity.shared.reminders = reminders
        Connectivity.shared.saveReminders()
        Connectivity.shared.send(reminder: reminder)
        
    }
    
}
