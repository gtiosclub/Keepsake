//
//  Reminder.swift
//  KeepsakeWatch Watch App
//
//  Created by Ishita on 2/17/25.
//

import Foundation
import SwiftUI
//
//// Reminder Model
struct Reminder: Identifiable, Codable {
    let id = UUID()
    var title: String
    var date: Date
    var body: String
}

//// Reminders View
//struct RemindersListView: View {
//    @State private var reminders: [Reminder] = [Reminder(title: "Meeting with John", date: Date().addingTimeInterval(3600), body: "Discuss project updates"), Reminder(title: "Complete Homework", date: Date().addingTimeInterval(5000), body: "Do Homework")]
//    @State private var showAddReminder = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // Static title at the top
////                Text("Reminders")
////                    .font(.title2)
////                    .fontWeight(.bold)
////                    .padding()
////                
//                // List of reminders
//                List {
//                    ForEach(reminders) { reminder in
//                        VStack(alignment: .leading) {
//                            Text(reminder.title)
//                                .font(.headline)
//                            Text("\(reminder.date.formatted(date: .abbreviated, time: .shortened))")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            Text(reminder.body)
//                                .font(.body)
//                        }
//                        .padding(.vertical, 5)
//                    }
//                }
//                .listStyle(PlainListStyle())  // Optional: adds cleaner look for the list
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading){
//                        Text("Reminders")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(hex: "FFADF4"))
//                    }
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: { showAddReminder.toggle()}) {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundColor(Color(hex: "FFADF4"))
//                                .font(.title2)
//                        }.buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .sheet(isPresented: $showAddReminder) {
//                    RemindersAddView(reminders: $reminders)  // Present the add view
//                }
//            }
////            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//
//struct RemindersAddView: View {
//    @Binding var reminders: [Reminder]
//    @State var title: String = ""
//    @State var note: String = ""
//    var body: some View {
//        VStack {
//            Form {
//                Section(header: Text("Reminder Title")) {
//                    TextField("Enter title", text: $title)
//                }
//            }
//            Form {
//                Section(header: Text("Notes")) {
//                    TextField("Enter Notes", text: $note)
//                }
//            }
//        }.toolbar() {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: {}) {
//                    Text("Add")
//                            .foregroundColor(.black)
//                            .font(.body)
//                            .padding()
//                            .background(Color(hex: "FFADF4"))
//                            .cornerRadius(15)
//                }.buttonStyle(PlainButtonStyle())
//            }
//        }
//    }
//}
//        
//        // Preview Provider
struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersListView()
    }
}

//struct RemindersListView: View {
//    @State private var reminders: [Reminder] = []
//    @State private var showVoiceRecording = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                List {
//                    ForEach(reminders) { reminder in
//                        VStack(alignment: .leading) {
//                            Text(reminder.title)
//                                .font(.headline)
//                            Text("\(reminder.date.formatted(date: .abbreviated, time: .shortened))")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.vertical, 5)
//                    }
//                }
//                .listStyle(PlainListStyle())
//                .toolbar {
//                    ToolbarItem(placement: .automatic) {
//                        Text("Reminders")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(hex: "FFADF4"))
//                    }
//                    ToolbarItem(placement: .automatic) {
//                        Button(action: { showVoiceRecording = true }) {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundColor(Color(hex: "FFADF4"))
//                                .font(.title2)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .sheet(isPresented: $showVoiceRecording) {
//                    VoiceRecordingView { recordedFile in
//                        reminders.append(recordedFile) // Already contains title and date
//                        showVoiceRecording = false // Dismiss after adding
//                    }
//                }
//            }
//        }
//    }
//}
//


struct RemindersListView: View {
    @EnvironmentObject var viewModel: RemindersViewModel

    var body: some View {
        List(viewModel.reminders) { reminder in
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .font(.headline)
                Text(reminder.date, style: .date)
                    .font(.subheadline)
                Text(reminder.body)
                    .font(.body)
            }
            .padding(.vertical, 5)
        }
        #if os(watchOS)
                NavigationLink(
                                    destination: TextReminder(),
                    label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "FFADF4"))
                            .font(.title)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.3)))
                            .shadow(radius: 10)
                    }
                )

                .buttonStyle(PlainButtonStyle()) // To remove default button style
        #endif

    }
}



//struct RemindersListView: View {
//    @State var reminders: [Reminder] = [
//        Reminder(title: "Sample Reminder", date: Date(), body: "Test Reminder Body")
//    ]
//    @State private var showVoiceRecording = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
////                Text("Reminders")
////                    .font(.body)
////                    .foregroundColor(.white)
//                
//                ForEach(reminders) { reminder in
//                    VStack(alignment: .leading) {
//                        Text(reminder.title)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                        Text("\(reminder.date.formatted(date: .abbreviated, time: .shortened))")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
////                        Text(reminder.body)
////                            .font(.title3)
////                            .foregroundColor(.white)
//                    }
//                    .padding(.vertical, 5)
//                }
//                
//                Spacer()
//                
//                // Custom button for navigating to Voice Recording
//#if os(watchOS)
//                NavigationLink(
//                                    destination: TextReminder(
////                                        reminders: reminders,
////                                        showVoiceRecording: showVoiceRecording,
////                                        onComplete: { newReminder in
////                                            // Send reminder to Connectivity after it's added
////                                            Connectivity.shared.send(reminder: newReminder)
////                                            reminders.append(newReminder)
////                                        }
//                                    ),
//                    label: {
//                        Image(systemName: "plus.circle.fill")
//                            .foregroundColor(Color(hex: "FFADF4"))
//                            .font(.title)
//                            .padding()
//                            .background(Circle().fill(Color.white.opacity(0.3)))
//                            .shadow(radius: 10)
//                    }
//                )
//
//                .buttonStyle(PlainButtonStyle()) // To remove default button style
//#endif
//            }
//
//            .background(Color.black.edgesIgnoringSafeArea(.all)) // Black background
//            .navigationTitle("Reminders")
//            
//        }
//    }
//}





//struct RemindersListView: View {
//    @State var reminders: [Reminder] = [
//        Reminder(title: "Sample Reminder", date: Date(), body: "Test Reminder Body")
//    ]
//    @State private var showVoiceRecording = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                List {
//                    ForEach(reminders) { reminder in
//                        VStack(alignment: .leading) {
//                            Text(reminder.title)
//                                .font(.headline)
//                            Text("\(reminder.date.formatted(date: .abbreviated, time: .shortened))")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.vertical, 5)
//                    }
//                }
//                .listStyle(PlainListStyle())
//                .toolbar {
//                    ToolbarItem(placement: .automatic) {
//                        Text("Reminders")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            
//                    }
//#if os(watchOS)
//                    ToolbarItem(placement: .automatic) {
//
//                        NavigationLink(
//                            destination: Choice(reminders: $reminders),
//                            label: {
//                                Image(systemName: "plus.circle.fill")
//                                    .foregroundColor(Color(hex: "FFADF4"))
//                                    .font(.title2)
//                            })
//  
//                        
//                    }
//                }
//                #endif
//            }
//            .background(Color.black.edgesIgnoringSafeArea(.all)) // Black background
//            .navigationTitle("Reminders")
//        }
//    }
//}
