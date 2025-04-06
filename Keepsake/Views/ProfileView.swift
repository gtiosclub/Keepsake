import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showImageOptions = false
    @State private var showCamera = false
    @State private var isCamera = false
    
    var body: some View {
        VStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            if let profileImage = viewModel.retrievedImage {
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
                            SettingsRowView(imageName: "person.2.fill", title: "View Friends", tintColor: .blue)
                        }
                    }
                    
                    Section("Audio Reminders") {
                        NavigationLink(
                            destination: AudioFilesView(),
                            label: {
                                HStack {
                                    Image(systemName: "headphones")
                                        .foregroundColor(Color(hex: "FFADF4"))
                                    Text("Audio Recordings")
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.3)))
                                .shadow(radius: 5)
                            }
                        )
                    }
                    
                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.backward.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                    }
                }
            }
        }
        .onAppear() {
           viewModel.getProfilePic()
            
        }
        .actionSheet(isPresented: $showImageOptions) {
            ActionSheet(title: Text("Select Profile Image"), buttons: [
                .default(Text("Camera")) {
                    self.isCamera = true
                    self.showImagePicker.toggle()
                },
                .default(Text("Photo Library")) {
                    self.isCamera = false
                    self.showImagePicker.toggle()
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerController(image: $profileImage, isCamera: isCamera)
        }
        .onChange(of: profileImage) { newImage in
            if let image = newImage {
                viewModel.storeProfilePic(image: image)
                
            }
        }
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
        .environmentObject(FirebaseViewModel())
}
