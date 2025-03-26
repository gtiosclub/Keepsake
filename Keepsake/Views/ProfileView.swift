
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showImageOptions = false
    @State private var showCamera = false

  
    
    var body: some View {
        VStack {
//            if let user = viewModel.currentUser {
            let user = User(id: "123", name: viewModel.currentUser?.name ?? "Nitya", journalShelves: [], scrapbookShelves: [])
                List {
                    Section {
                        HStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        showImageOptions.toggle()
                                    }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        showImageOptions.toggle()
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top)

                                Text(user.username)

                                    .font(.footnote)
                                    .accentColor(.pink)
                            }
                        }
                    }
                    

                    Section("Friends") {
                        NavigationLink(destination: FriendsView()) {
                            SettingsRowView(imageName: "person.2.fill",
                                            title: "View Friends",
                                            tintColor: .blue)
                        }
                    }
                    Section("Content") {
                        NavigationLink(destination: ContentView(userVM: UserViewModel(user: User(id: "123", name: "Steve", journalShelves: [JournalShelf(name: "Bookshelf", id: UUID(), journals: [
                            Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(name: "Template 1", coverColor: .red, pageColor: .white, titleColor: .black, texture: .leather), pages: [JournalPage(number: 1), JournalPage(number: 2, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.55, 0.8, 0.8]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 1), JournalPage(number: 3, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 1, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(date: "03/04/25", title: "Shopping Haul", text: "irrelevant", summary: "Got some neat shirts and stuff", width: 1, height: 2, isFake: false, color: [0.6, 0.7, 0.6]), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.9, 0.5, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 3), JournalPage(number: 4, entries: [JournalEntry(date: "03/04/25", title: "Shake Recipe", text: "irrelevant", summary: "Recipe for great protein shake", width: 2, height: 2, isFake: false, color: [0.5, 0.9, 0.7]), JournalEntry(), JournalEntry(), JournalEntry(), JournalEntry(date: "03/04/25", title: "Daily Reflection", text: "irrelevant", summary: "Went to classes and IOS club", width: 2, height: 2, isFake: false, color: [0.6, 0.55, 0.8]), JournalEntry(), JournalEntry(), JournalEntry()], realEntryCount: 2), JournalPage(number: 5)], currentPage: 3),
                            Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(name: "Tempalte 2", coverColor: .green, pageColor: .white, titleColor: .black, texture: .bears), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .stars), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: Texture.green), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
                        ]), JournalShelf(name: "Shelf 2", id: UUID(), journals: [
                            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
                            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
                        ])], scrapbookShelves: [])), aiVM: AIViewModel(), fbVM: FirebaseViewModel())) {
                            SettingsRowView(imageName: "person.2.fill",
                                            title: "View Content",
                                            tintColor: .blue)
                        }
                    }

                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {

                            SettingsRowView(imageName: "arrow.backward.circle.fill",

                                            title: "Sign Out",
                                            tintColor: .red)
                        }
                        .foregroundColor(.pink)
                    }

                }
                .actionSheet(isPresented: $showImageOptions) {
                    ActionSheet(
                        title: Text("Choose an option"),
                        message: Text("Select a photo source"),
                        buttons: [
                            .default(Text("Take Photo")) {
                                showCamera.toggle()
                            },
                            .default(Text("Choose from Gallery")) {
                                showImagePicker.toggle()
                            },
                            .cancel()
                        ]
                    )
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerController(image: $profileImage)
                }
                .sheet(isPresented: $showCamera) {
                    ImagePickerController(image: $profileImage, isCamera: true)

                }
                .navigationTitle("Profile")
            }
//        }
    }
}

struct ImagePickerController: View {
    @Binding var image: UIImage?
    var isCamera: Bool = false
    
    var body: some View {
        ImagePickerViewController(image: $image, isCamera: isCamera)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ImagePickerViewController: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var isCamera: Bool
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var image: UIImage?
        
        init(image: Binding<UIImage?>) {
            _image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                image = selectedImage
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = isCamera ? .camera : .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
