import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var viewModel: FirebaseViewModel
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showImageOptions = false
    @State private var showCamera = false
    @State private var isCamera = false
    @State private var streaks: Int = 0
    @State private var showStreak = false
    @State private var pulse = false
    @State private var remindersWithAudio: [(reminder: Reminder, audioUrl: String)] = []
    @State var retrievedImage: UIImage?
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    profileCard
                    streakCard
                    NavigationLink(destination: FriendsView()) {
                        settingBox(icon: "person.2.fill", title: "View Friends", color: .blue)
                    }
                    NavigationLink(destination: AudioFilesView(remindersWithAudio: remindersWithAudio).environmentObject(viewModel)) {
                        settingBox(icon: "headphones", title: "Audio Recordings", color: Color(hex: "FFADF4"))
                    }

                    Button {
                        viewModel.signOut()
                    } label: {
                        settingBox(icon: "arrow.backward.circle.fill", title: "Sign Out", color: .red)
                    }
                    
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                fetchStreaks()
                fetchAllAudioFiles()
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


    var profileCard: some View {
        HStack(alignment: .center, spacing: 16) {
            if let profileImage = retrievedImage {
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

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.currentUser?.name ?? "Name")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("@\(viewModel.currentUser?.username ?? "username")")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "FFADF4"))
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 3))
    }


    var streakCard: some View {
        HStack(spacing: 8) {
            Text("🔥")
                .font(.largeTitle)
                .scaleEffect(pulse ? 1.2 : 1.0)
                .animation(pulse ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: pulse)

            Text("Streak: \(streaks)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .offset(x: showStreak ? 0 : -200)
        .opacity(showStreak ? 1 : 0)
        .animation(.easeOut(duration: 0.6), value: showStreak)
        .onAppear {
            showStreak = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                pulse = true
            }
        }
    }

    func settingBox(icon: String, title: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)

            Text(title)
                .foregroundColor(.primary)
                .fontWeight(.medium)

            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 2))
    }
    func fetchStreaks() {
        let db = viewModel.db
        db.collection("USERS").document(viewModel.currentUser?.id ?? "").getDocument { snapshot, error in
            if let data = snapshot?.data(), let streaks = data["streaks"] as? Int {
                DispatchQueue.main.async {
                    self.streaks = streaks
                }
            }
        }
    }
    func fetchAllAudioFiles() {
        #if os(iOS)
        Task {
            await Connectivity.shared.fetchAudioFiles()
            print("in audio files doc this is connectviity: \(Connectivity.shared.remindersWithAudio.count)")
            remindersWithAudio = Connectivity.shared.remindersWithAudio
        }
        #endif
        #if os(watchOS)
        Connectivity.shared.requestAudioFiles()
        #endif
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


