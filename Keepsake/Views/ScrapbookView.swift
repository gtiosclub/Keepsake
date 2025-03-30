import SwiftUI
import RealityKit
import PhotosUI
import MultipeerConnectivity


struct ScrapbookView: View {
    @StateObject private var arvm = ARViewModel()
    
    // variables for editing entity positions
    @State var currentScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var currentRotation: Angle = .zero
    @State var finalRotation: Angle = .zero
    
    @State var isTextClicked: Bool = false
    @State var isImageClicked: Bool = false
    
    @State var anchor: AnchorEntity? = nil
    @State var selectedEntity: Entity? = nil
    
    // determining if any edits have been made to save
    @State var needsSaving: Bool = false
    
    // counter value is used to identify entities
    @State var counter: Int = 0
    @State var entityPos: [UnitPoint] = []
    
    @State var selectedItem: PhotosPickerItem?
    @State var currImage: UIImage?
    @State var images: [UIImage] = []
    
    @State private var textInput: String = "[Enter text]"
    @State var isEditing: Bool = false
    
    @StateObject private var multipeerSession: MultipeerSession

    init() {
        let receivedDataHandler: (Data, MCPeerID) -> Void = { data, peerID in
            print("yoooo")
        }

        let peerJoinedHandler: (MCPeerID) -> Void = { peerID in
            print("Peer joined: \(peerID.displayName)")
        }

        let peerLeftHandler: (MCPeerID) -> Void = { peerID in
            print("Peer left: \(peerID.displayName)")
        }

        let peerDiscoveredHandler: (MCPeerID) -> Bool = { peerID in
            print("Peer discovered: \(peerID.displayName)")
            return true
        }

        _multipeerSession = StateObject(
            wrappedValue: MultipeerSession(
                username: UIDevice.current.name,
                receivedDataHandler: receivedDataHandler,
                peerJoinedHandler: peerJoinedHandler,
                peerLeftHandler: peerLeftHandler,
                peerDiscoveredHandler: peerDiscoveredHandler
            )
        )
    }

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                
                let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                self.anchor = newAnchor
                content.add(newAnchor)

            } update: { content in
                if isTextClicked {
                    Task {
                        let newTextbox = await TextBoxEntity(text: "[Enter text]")
                        newTextbox.name = "\(counter)"
                        entityPos.append(.zero)
                        counter += 1
                        self.anchor?.addChild(newTextbox)
                        
                        self.sendEntityUpdate(newTextbox, image: nil)
                    }
                }
                if isImageClicked {
                    Task {
                        await loadImage()
                        if let validImage = currImage {
                            let newImage = await ImageEntity(image: validImage)
                            newImage.name = "\(counter)"
                            entityPos.append(.zero)
                            counter += 1
                            self.anchor?.addChild(newImage)
                            isImageClicked = false
                            self.sendEntityUpdate(newImage, image: validImage)
                        } else {
                            print("No image loaded")
                        }
                        needsSaving = true
                    }
                }
            }
            .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity()
                .onEnded{ value in
                    if let selected = value.hitTest(point: value.location, in: .local).first?.entity.parent {
                        selectedEntity = selected
                    }
                    print(selectedEntity?.name ?? "No Entity Selected")
                })

            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged { value in
                    let position = entityPos[Int(selectedEntity?.name ?? "0") ?? 0]
                    let dy = Float(value.translation.height + position.y) * 0.002
                    let maxAngle: Float = .pi / 2.5
                    let dx = Float(value.translation.width + position.x) * 0.002
                    selectedEntity?.position.x = dx
                    selectedEntity?.position.y = -dy

                    let clampedDX = min(max(dx, -maxAngle), maxAngle)
                    let clampedDY = min(max(dy, -maxAngle), maxAngle)
                            
                    let horizontalRotation = simd_quatf(angle: -clampedDX, axis: SIMD3<Float>(0, 1, 0))
                    let verticalRotation = simd_quatf(angle: -clampedDY, axis: SIMD3<Float>(1, 0, 0))
                    
                    selectedEntity?.transform.rotation = horizontalRotation * verticalRotation
                    
                    if let selectedEntity = selectedEntity {
                        sendEntityUpdate(selectedEntity, image: nil)
                    }
                }
                .onEnded { value in
                    entityPos[Int(selectedEntity?.name ?? "0") ?? 0].x += value.translation.width
                    entityPos[Int(selectedEntity?.name ?? "0") ?? 0].y += value.translation.height
                    needsSaving = true
                }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = finalScale * value
                        selectedEntity?.scale = SIMD3<Float>(repeating: Float(currentScale))
                        
                        if let selectedEntity = selectedEntity {
                            sendEntityUpdate(selectedEntity, image: nil)
                        }
                    }
                    .onEnded { value in
                        finalScale = currentScale
                        needsSaving = true
                        
                        if let selectedEntity = selectedEntity {
                            sendEntityUpdate(selectedEntity, image: nil)
                        }
                    }
            )

            VStack {
                Spacer()
                if isEditing {
                    VStack {
                        TextField("Edit Text", text: $textInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .onSubmit {
                                updateTextBox()
                                isEditing = false
                                textInput = "[Enter text]"
                            }
    
                        Button("Done") {
                            updateTextBox()
                            isEditing = false
                            textInput = "[Enter text]"
                            needsSaving = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: 250)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(15)
                    .padding()
                }
                

                HStack {
                    PhotosPicker (selection: $selectedItem, matching: .images){
                        Image(systemName: "photo")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }.onChange(of: selectedItem) { _, _ in
                        isImageClicked = true
                    }
                    Spacer()
                    Button {
                        isTextClicked = true
                        Task {
                            try await Task.sleep(nanoseconds: 10_000)
                            isTextClicked = false
                        }
                    } label: {
                        Image(systemName: "note.text.badge.plus")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    ZStack {
                        Button {
                            isEditing = true
                            print("pressed")
                        } label : {
                            Text("Edit \(selectedEntity?.name ?? "")")
                        }.disabled(selectedEntity == nil)
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .frame(width: 80, height: 40)
                        Button {
                            print("pressed")
                        } label : {
                            Text("Save").foregroundStyle(.black)
                        }.disabled(needsSaving == false)
                    }

                    
                }
                .padding()
                .frame(width: 325, height: 100)
                .background(Color.white.opacity(0.5)) // Semi-transparent background
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 20) // Lifted up slightly
            }
        }.task {
            let result = await FirebaseViewModel.vm.testRead()
            print("Firebase test result:", result)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            multipeerSession.receivedDataHandler = { data, peerID in
                if let entityUpdate = try? JSONDecoder().decode(EntityUpdate.self, from: data) {
                    DispatchQueue.main.async {
                        self.updateEntity(with: entityUpdate)
                    }
                }
            }
        }
        .onDisappear {
            multipeerSession.serviceAdvertiser.stopAdvertisingPeer()
            multipeerSession.serviceBrowser.stopBrowsingForPeers()
        }
    }
    
    private func loadImage() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
                currImage = uiImage
            }
        }
    }
    
    private func updateTextBox() {
        if let editingTextEntity = selectedEntity as? TextBoxEntity {
            editingTextEntity.updateText(textInput)
            
            sendEntityUpdate(editingTextEntity, image: nil)
        }
    }
    
    private func sendEntityUpdate(_ entity: Entity, image: UIImage?) {
        var text: String? = nil
        var imageData: Data? = nil
        
        if let textEntity = entity as? TextBoxEntity {
            text = textEntity.getText()
        } else if let imageEntity = entity as? ImageEntity, let uiImage = image  {
            imageData = compressImage(uiImage, compressionQuality: 0.8)
        }
        
        let entityUpdate = EntityUpdate(
            id: entity.name,
            type: entity is TextBoxEntity ? "text" : "image",
            position: entity.position,
            scale: entity.scale,
            rotation: entity.transform.rotation,
            text: text,
            imageData: imageData
        )
    
        if let data = try? JSONEncoder().encode(entityUpdate) {
            multipeerSession.sendToAllPeers(data, reliably: true)
        }
    }
    
    private func compressImage(_ image: UIImage, compressionQuality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }


    private func updateEntity(with update: EntityUpdate) {
        if let existingEntity = anchor?.children.first(where: { $0.name == update.id }) {
            // Update existing entity
            existingEntity.position = update.position
            existingEntity.scale = update.scale
            existingEntity.transform.rotation = update.rotation.quaternion
            
            if let textEntity = existingEntity as? TextBoxEntity, let text = update.text {
                textEntity.updateText(text)
            }
             
        } else {
            
            
            Task {
                if update.type == "text", let text = update.text {
                    // Create a new text box
                    print("made new textbox")
                    let newTextbox = await TextBoxEntity(text: text)
                    newTextbox.name = update.id
                    newTextbox.position = update.position
                    newTextbox.scale = update.scale
                    newTextbox.transform.rotation = update.rotation.quaternion
                    
                    entityPos.append(.zero)
                    counter += 1
                    
                    
                    DispatchQueue.main.async {
                        self.anchor?.addChild(newTextbox)
                    }
                } else if update.type == "image", let imageData = update.imageData, let uiImage = UIImage(data: imageData) {
                    // Create a new image entity
                    print("transfer here")
                    let newImage = await ImageEntity(image: uiImage)
                    newImage.name = update.id
                    newImage.position = update.position
                    newImage.scale = update.scale
                    newImage.transform.rotation = update.rotation.quaternion
                    
                    entityPos.append(.zero)
                    counter += 1
                    
                    DispatchQueue.main.async {
                        self.anchor?.addChild(newImage)
                    }
                }
            }
        }
    }
    
}
