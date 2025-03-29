
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showImageOptions = false
    @State private var showCamera = false

  
    
    var body: some View {
        VStack {
            if let user = viewModel.currentUser {

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
