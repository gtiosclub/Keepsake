//
//  ViewModelConnectivity.swift
//  KeepsakeWatch Watch App
//
//  Created by Nitya Potti on 3/15/25.
//


//import Combine
//import SwiftUI
//
//final class RemindersViewModel: ObservableObject {
//    @Published var reminders: [Reminder] = []
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        Connectivity.shared.$reminders
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$reminders)
//    }
//
//    func addReminder(_ reminder: Reminder) {
//        reminders.append(reminder)
//        Connectivity.shared.send(reminder: reminder)
//    }
//}


import Combine
import SwiftUI

final class RemindersViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        
        Connectivity.shared.$reminders
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .assign(to: &$reminders)
    }

    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        Connectivity.shared.reminders = reminders
        Connectivity.shared.saveReminders()
        Connectivity.shared.send(reminder: reminder)
        
    }
}
