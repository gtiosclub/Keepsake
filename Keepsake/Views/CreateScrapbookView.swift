//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit
import PhotosUI
import UIKit
import MultipeerConnectivity

struct CreateScrapbookView: View {
    @ObservedObject var fbVM: FirebaseViewModel
    @ObservedObject var userVM: UserViewModel
    var scrapbook: Scrapbook
    // variables for editing entity positions
    @State var currentScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var currentRotation: Angle = .zero
    @State var finalRotation: Angle = .zero
    
    // connects the buttons in tool bar to functionality in RealityKit's update closure
    @State var isTextClicked: Bool = false
    @State var isImageClicked: Bool = false
    
    // anchor for all entities in RealityView
    @State var anchor: AnchorEntity? = nil
    
    // entity that is tapped on and currently "selected"
    @State var selectedEntity: Entity? = nil
    
    // counter value is used to identify entities
    @State var counter: Int = 0
    
    // array that holds the drag positions for each entity
    @State var entityPos: [UnitPoint] = []
    
    // for adding images
    @State var selectedItem: PhotosPickerItem?
    @State var currImage: UIImage?
    @State var images: [UIImage] = []
    
    // for editing text and text font options
    @State private var textInput: String = "[Enter text]"
    @State var isEditing: Bool = false
    @State private var selectedFont: String = "Helvetica"
    @State private var fontSize: CGFloat = 200
    @State private var backgroundColorUI: Color = Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.8)
//    @State private var backgroundColor: CGColor = CGColor(gray: 0.5, alpha: 0.8)
    @State private var textColor: Color = .black
    @State private var textAlignment: NSTextAlignment = .center
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var showTextColorPicker: Bool = false
    @State private var showBackgroundColorPicker: Bool = false
    let fontOptions = ["Helvetica", "Times New Roman", "Courier", "Comic Sans", "Arial", "Impact", "Lato", "Oswald"]
    let fontSizes: [CGFloat] = Array(stride(from: 100, to: 300, by: 10))
    let buttonSize: CGFloat = 50
    
    @State private var isExpanded = false
    @State private var animationInProgress = false
    
    @State private var isCustomizingImage: Bool = false
    
    @State var noFrameSelected: Bool = true
    @State var polaroidFrameSelected: Bool = false
    @State var flowerFrameSelected: Bool = false
    
    @State var isPublished: Bool = false
    @State var isShareShowing: Bool = false
    @State var isCollaborating: Bool = false
    
    @StateObject private var multipeerSession: MultipeerSession
    
    init(fbVM: FirebaseViewModel, userVM: UserViewModel, scrapbook: Scrapbook) {
        self.fbVM = fbVM
        self.userVM = userVM
        self.scrapbook = scrapbook
        
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
            ARView
                .ignoresSafeArea()
                .gesture(tapGesture)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
            
            VStack {
                //Spacer()
                if isEditing {
                    TextEditView
                    // Spacer()
                } else if isCustomizingImage {
                    Spacer()
                    ImageCustomizationView
                } else if isShareShowing {
                    Spacer()
                    ShareView
                } else {
                    Spacer()
                    ToolBarView
                        .padding()
                        .padding(.bottom, 20)
                }
            }.ignoresSafeArea(edges: .bottom)
        }
        .onDisappear {
            Task {
                userVM.clearScrapbookPage(scrapbook: scrapbook, pageNum: 0)
                if let anchor = anchor {  // Replace `self.anchor` with your actual anchor
                    for entity in anchor.children {
                        if let textEntity = entity as? TextBoxEntity {
                            print("text color \(textEntity.getText()) \(textEntity.currentTextColor)")
                            let entry = ScrapbookEntry(id: UUID(), type: "text", position: [textEntity.position.x, textEntity.position.y, textEntity.position.z], scale: textEntity.scale.x, rotation: [textEntity.transform.rotation.vector.x, textEntity.transform.rotation.vector.y, textEntity.transform.rotation.vector.z, textEntity.transform.rotation.vector.w], text: textEntity.getText(), imageURL: "nil", font: textEntity.currentFont, fontSize: Int(textEntity.currentSize), isBold: textEntity.currentIsBold, isItalic: textEntity.currentIsItalic, textColor: colorToFloatArray(textEntity.currentTextColor), backgroundColor: cgColorToFloatArray(textEntity.currentBackgroundColor))
                            
                            userVM.updateScrapbookEntry(scrapbook: scrapbook, pageNum: 0, newEntry: entry)
                        } else if let imageEntity = entity as? FramedImageEntity {
                            let url = await fbVM.convertImageToURL(image: imageEntity.image)
                        
                            
                            let entry = ScrapbookEntry(id: UUID(), type: "image", position: [imageEntity.position.x, imageEntity.position.y, imageEntity.position.z], scale: imageEntity.scale.x, rotation: [imageEntity.transform.rotation.vector.x, imageEntity.transform.rotation.vector.y, imageEntity.transform.rotation.vector.z, imageEntity.transform.rotation.vector.w], text: "", imageURL: url, frame: (imageEntity.frameType == .classic) ? "classic" : "polaroid")
                            
                            userVM.updateScrapbookEntry(scrapbook: scrapbook, pageNum: 0, newEntry: entry)
                        }
                    }
                    
                    await fbVM.updateScrapbookPage(entries: scrapbook.pages[0].entries, scrapbookID: scrapbook.id, pageNumber: 1)
                }
            }
        }
    }
    
    // RealityKit View
    private var ARView: some View {
        RealityView { content in
            content.camera = .spatialTracking
            
            // creates new anchor and makes that "global" anchor
            let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
            self.anchor = newAnchor
            content.add(newAnchor)
            
            let scrapbookPage = scrapbook.pages[0]
            
            print(scrapbookPage.entries)
            
            
            for entry in scrapbookPage.entries {
                var entity = Entity()
                if entry.type == "text" {
                    entity = await TextBoxEntity(text: entry.text ?? "[Blank]", font: entry.font, size: CGFloat(entry.fontSize), isBold: entry.isBold, isItalic: entry.isItalic, isUnderlined: false, textColor: Color(red: Double(entry.textColor[0]), green: Double(entry.textColor[1]), blue: Double(entry.textColor[2])), backgroundColor: CGColor(red: Double(entry.backgroundColor[0]), green: Double(entry.backgroundColor[1]), blue: Double(entry.backgroundColor[2]), alpha: 1.0))
                    
                } else if entry.type == "image" {
                    entity = await FramedImageEntity(image: fbVM.getImageFromURL(urlString: entry.imageURL ?? "") ?? UIImage(), frameType: (entry.frame == "classic") ? FrameType.classic : FrameType.polaroid)
                }
                
                entity.name = "\(counter)"
                counter += 1
                entityPos.append(.zero)
                entity.position = SIMD3<Float>(x: entry.position[0], y: entry.position[1], z: entry.position[2])
                entity.scale = SIMD3<Float>(repeating: Float(entry.scale))
                
                
                // Combine rotations (order matters)
                let rotation = simd_quatf(ix: entry.rotation[0], iy: entry.rotation[1], iz: entry.rotation[2], r: entry.rotation[3])
                entity.transform.rotation = rotation
                
                self.anchor?.addChild(entity)
            }
        }
    }
    
    private var ToolBarView: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 12) {
                // Only show these buttons when expanded
                if isExpanded {
                    PhotosPicker (selection: $selectedItem, matching: .images){
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: buttonSize, height: buttonSize)
                            
                            Image(systemName: "photo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }.onChange(of: selectedItem) { _, _ in
                        Task {
                            await loadImage()
                        }
                        isCustomizingImage = true
                    }
        
                    Button {
                        Task {
                            let newTextbox = await TextBoxEntity(text: "[Enter text]")
                            newTextbox.name = "\(counter)"
                            entityPos.append(.zero)
                            counter += 1
                            self.anchor?.addChild(newTextbox)
                            
                            await self.sendEntityUpdate(newTextbox)
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: buttonSize, height: buttonSize)
                            
                            Image(systemName: "textformat")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    Button {
                        if let selectedTextEntity = selectedEntity as? TextBoxEntity {
                            // Populate state variables with current attributes from the entity
                            textInput = selectedTextEntity.getText()
                            selectedFont = selectedTextEntity.currentFont
                            fontSize = selectedTextEntity.currentSize
                            isBold = selectedTextEntity.currentIsBold
                            isItalic = selectedTextEntity.currentIsItalic
                            isUnderlined = selectedTextEntity.currentIsUnderlined
                            textColor = selectedTextEntity.currentTextColor
//                            backgroundColor = selectedTextEntity.currentBackgroundColor
                            if let components = selectedTextEntity.currentBackgroundColor.components {
                                if components.count >= 4 {
                                    backgroundColorUI = Color(.sRGB,
                                                            red: Double(components[0]),
                                                            green: Double(components[1]),
                                                            blue: Double(components[2]),
                                                            opacity: Double(components[3]))
                                } else if components.count >= 2 {  // Handle grayscale
                                    backgroundColorUI = Color(.sRGB,
                                                            red: Double(components[0]),
                                                            green: Double(components[0]),
                                                            blue: Double(components[0]),
                                                            opacity: Double(components[1]))
                                }
                            }
                        }
                        isEditing = true
                    } label : {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: buttonSize, height: buttonSize)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }.disabled(selectedEntity == nil)
                    
                    Button {
                        if let selected = selectedEntity{
                            anchor?.removeChild(selected)
                        }
                    } label : {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: buttonSize, height: buttonSize)
                            
                            Image(systemName: "trash")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }.disabled(selectedEntity == nil)
                    
                    Button {
                        isShareShowing = true
                    } label : {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: buttonSize, height: buttonSize)
                            
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                    toggleButton
            }
                    .padding(.vertical, 8)
                    .padding(.horizontal, isExpanded ? 10 : 0)
                    .frame(width: isExpanded ? nil : buttonSize, height: isExpanded ? buttonSize + 16 : buttonSize)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isExpanded)
        }
    }
    
    private var toggleButton: some View {
        Button(action: {
            if !animationInProgress {
                withAnimation {
                    animationInProgress = true
                    isExpanded.toggle()
                }
                
                // Reset animation flag after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    animationInProgress = false
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: buttonSize, height: buttonSize)
                
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.spring(response: 0.4), value: isExpanded)
            }
        }
    }
    
    private var ImageCustomizationView: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            VStack {
                if let validImage = currImage {
                    Image(uiImage: validImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                } else {
                    Rectangle()
                        .frame(width: 250, height: 300)
                        .foregroundStyle(.white)
                        .padding(.bottom, 20)
                }
                Text("Frames")
                    .frame(width: 350, height: 25)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(20)
                
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            noFrameSelected = true
                            polaroidFrameSelected = false
                            flowerFrameSelected = false
                        }
                    } label: {
                        Image("no_frame")
                            .shadow(color: noFrameSelected ? Color.black.opacity(0.3) : Color.clear,
                                    radius: noFrameSelected ? 10 : 0, x: 0, y: 5)
                            .offset(y: noFrameSelected ? -5 : 0)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            noFrameSelected = false
                            polaroidFrameSelected = true
                            flowerFrameSelected = false
                        }
                    } label: {
                        Image("polaroid_frame")
                            .shadow(color: polaroidFrameSelected ? Color.black.opacity(0.3) : Color.clear,
                                    radius: polaroidFrameSelected ? 10 : 0, x: 0, y: 5)
                            .offset(y: polaroidFrameSelected ? -5 : 0)
                            .offset(x: 13)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            noFrameSelected = false
                            polaroidFrameSelected = false
                            flowerFrameSelected = true
                        }
                    } label: {
                        Image("flower_frame")
                            .shadow(color: flowerFrameSelected ? Color.black.opacity(0.3) : Color.clear,
                                    radius: flowerFrameSelected ? 10 : 0, x: 0, y: 5)
                            .offset(y: flowerFrameSelected ? -5 : 0)
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isCustomizingImage = false
                        
                        Task {
                            if let validImage = currImage {
                                var frameType = FrameType.classic
                                if polaroidFrameSelected {
                                    frameType = FrameType.polaroid
                                }
                                let newImage = await FramedImageEntity(image: validImage, frameType: frameType)
                                newImage.name = "\(counter)"
                                entityPos.append(.zero)
                                counter += 1
                                self.anchor?.addChild(newImage)
                                
                                await self.sendEntityUpdate(newImage)
                                
                                // MAKE SURE THIS ISNT BUGGY
                                noFrameSelected = true
                                polaroidFrameSelected = false
                                flowerFrameSelected = false
                                isImageClicked = false
                            } else {
                                print("No image loaded")
                            }
                        }
                    } label: {
                        Text("Done")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .padding(20)
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
    }
    
    private var TextEditView: some View {
        VStack (spacing: 12) {
            // Place to input new/updated text
                TextField("Edit Text", text: $textInput)
                  .padding()
                  .background(Color.pink.opacity(0.2))
                  .cornerRadius(10)
                  .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.5)))
                  .padding(.horizontal, 30)

              HStack {
                  // Menu for updating font family
                  Menu {
                      ForEach(fontOptions, id: \.self) { font in
                          Button(font) {
                              selectedFont = font
                          }
                      }
                  } label: {
                      HStack {
                          Text(selectedFont)
                              .foregroundStyle(.black)
                              .frame(width: 150, height: 30)
                              .background(Color.white.opacity(0.4))
                              .cornerRadius(12)
                      }
                  }
                  Spacer()

                  // Menu for updating font size
                  Menu {
                      ForEach(fontSizes, id: \.self) { size in
                          Button("\(Int(size))") {
                              fontSize = size
                          }
                      }
                  } label: {
                      Text("\(Int(fontSize))")
                          .foregroundStyle(.black)
                          .frame(width: 120, height: 30)
                          .background(Color.white.opacity(0.4))
                          .cornerRadius(12)
                  }
              }.padding(.horizontal, 30)
              
              // Font Styling Buttons
            HStack {
                HStack(spacing: 20) {
                    Toggle(isOn: $isBold) {
                        Text("B").bold()
                            .foregroundStyle(.black)
                    }
                    .toggleStyle(.button)
                    
                    Toggle(isOn: $isItalic) {
                        Text("I").italic()
                            .font(Font.custom("Times New Roman", size: 18))
                            .foregroundStyle(.black)
                        
                    }
                    .toggleStyle(.button)
                    
                    Toggle(isOn: $isUnderlined) {
                        Text("U").underline()
                            .foregroundStyle(.black)
                    }
                    .toggleStyle(.button)
                }
                Spacer()
                
                // Text Alignment
                HStack(spacing: 20) {
                    Button(action: { textAlignment = .left }) {
                        Image(systemName: "text.alignleft")
                    }
                    Button(action: { textAlignment = .center }) {
                        Image(systemName: "text.aligncenter")
                    }
                    Button(action: { textAlignment = .right }) {
                        Image(systemName: "text.alignright")
                    }
                }
                .font(.system(size: 18))
                .foregroundColor(.primary)
            }.padding(.horizontal, 30)
              
              // Text Color & Background Buttons
              HStack {
                  Button {
                      UIColorWellHelper.helper.execute?()
                  } label: {
                      Text("text color")
                          .frame(width: 150, height: 30)
                          .background(Color.black.opacity(0.6))
                          .foregroundColor(.white)
                          .cornerRadius(12)
                          .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.8)))
                  }
                  .background(
                    ColorPicker("", selection: $textColor, supportsOpacity: false)
                          .labelsHidden().opacity(0)
                  )
                  Spacer()
                  Button {
                      UIColorWellHelper.helper.execute?()
                  } label: {
                      Text("background")
                          .frame(width: 120, height: 30)
                          .background(Color.pink.opacity(0.2))
                          .foregroundColor(.white)
                          .cornerRadius(12)
                          .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.8)))
                  }
                  .background(
                    ColorPicker("", selection: $backgroundColorUI, supportsOpacity: true)
                          .labelsHidden().opacity(0)
                  )
              }.padding(.horizontal, 30)
            
            Button {
                updateTextBox()
                isEditing = false
                textInput = "[Enter text]"
            } label: {
                Text("Done")
                    .frame(width: 290, height: 30)
                    .background(Color.white.opacity(0.6))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.8)))
            }
        }
        .frame(width: 350, height: 260)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding()
    }
    
    private var ShareView: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            VStack {
                Text("Share")
                    .font(.system(size: 30, weight: .bold))
                Spacer()
                Toggle(isOn: $isPublished) {
                    Text("Publish to Community")
                        .font(.system(size: 20))
                }
                HStack {
                    Text("Anyone will be able to view this Scrapbook if published")
                        .font(.system(size: 12, weight: .bold))
                        .italic()
                    Spacer()
                }.padding(.vertical, 3)
                Spacer()
                Toggle(isOn: $isCollaborating) {
                    Text("Enable Real-time Collaboration")
                        .font(.system(size: 20))
                }
                HStack {
                    Text("People around you will be able to work on this Scrapbook")
                        .font(.system(size: 12, weight: .bold))
                        .italic()
                    Spacer()
                }.padding(.vertical, 3)
                Spacer()
            }.padding()
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShareShowing = false
                        
                        if isCollaborating {
                            print("yooo we collaborating now")
                            multipeerSession.receivedDataHandler = { data, peerID in
                                if let entityUpdate = try? JSONDecoder().decode(ScrapbookEntry.self, from: data) {
                                    DispatchQueue.main.async {
                                        self.updateEntity(with: entityUpdate)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                }.padding()
                Spacer()
            }.padding(10)
            
        }.frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    // drag gesture to move the entities around in a sphere-like shape
    // gets change in 2D drag distance and converts that into 3D transformations
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .global)
            .onChanged { value in
                // Gets the last known position for the selected entity and edits from there
                // note the position is not its 3D position, its the 2D location of where the dragGesture ended
                // the name of an entity is its index in the position array
                let position = entityPos[Int(selectedEntity?.name ?? "0") ?? 0]
                let dy = Float(value.translation.height + position.y) * 0.002
                let maxAngle: Float = .pi / 2.5  // 45 degrees in radians
                let dx = Float(value.translation.width + position.x) * 0.002
                selectedEntity?.position.x = dx
                selectedEntity?.position.y = -dy
                
                // Clamp the horizontal rotation angle:
                let clampedDX = min(max(dx, -maxAngle), maxAngle)
                let clampedDY = min(max(dy, -maxAngle), maxAngle)
                
                // Create the rotation using the clamped value:
                let horizontalRotation = simd_quatf(angle: -clampedDX, axis: SIMD3<Float>(0, 1, 0))
                let verticalRotation = simd_quatf(angle: -clampedDY, axis: SIMD3<Float>(1, 0, 0))
                
                // Combine rotations (order matters)
                selectedEntity?.transform.rotation = horizontalRotation * verticalRotation
            }
            .onEnded { value in
                // Store final translation offsets
                entityPos[Int(selectedEntity?.name ?? "0") ?? 0].x += value.translation.width
                entityPos[Int(selectedEntity?.name ?? "0") ?? 0].y += value.translation.height
            }
    }
    
    // Tap gesture that changes the selectedEntity to the entity you click on
    var tapGesture: some Gesture {
        SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity()
            .onEnded{ value in
                /*
                 hitTest creates a ray at value.location and returns a list of CollisionCastHits that it encounters
                 We then use the first CollisionCastHit and get it's entity's parent
                 We get the parent instead of just the entity because
                 the entity will be the collsion shape attached to the entity instead of the entity itself
                 */
                
                let hits = value.hitTest(point: value.location, in: .local)
//                if let closestHit = hits.sorted(by: { $0.distance < $1.distance }).first {
                //   selectedEntity = closestHit.entity.parent
                //}
                
//                if let selected = value.hitTest(point: value.location, in: .local).first?.entity.parent {
                if let closestHit = hits.sorted(by: { $0.distance < $1.distance }).first {
                    if let previousSelected = selectedEntity as? TextBoxEntity{
                        previousSelected.setSelected(false)
                    } else if let previousSelected = selectedEntity as? FramedImageEntity{
                        previousSelected.setSelected(false)
                    }
//                    selectedEntity = selected
                    selectedEntity = closestHit.entity.parent
                    if let nextSelected = selectedEntity as? TextBoxEntity{
                        nextSelected.setSelected(true)
                        print("changing opacity")
                    } else if let nextSelected = selectedEntity as? FramedImageEntity{
                        nextSelected.setSelected(true)
                        print("changing opacity")
                    }
                }
                print(selectedEntity?.name ?? "No Entity Selected")
            }
    }
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
            // Update current scale based on the gesture
            currentScale = finalScale * value
            
            // Apply scale to the entity
            if let entity = selectedEntity {
                entity.scale = SIMD3<Float>(repeating: Float(currentScale))
                // Update collision shape to match new scale
                updateCollisionShape(for: entity, scale: Float(currentScale))
            }
        }
        .onEnded { value in
            // Store the final scale for next gesture
            finalScale = currentScale
            
            // Ensure collision shape is updated with final scale
            if let entity = selectedEntity {
                updateCollisionShape(for: entity, scale: Float(finalScale))
            }
        }
    }
    
    // function to get a UIImage out of a PhotosPickerItem
    private func loadImage() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
                currImage = uiImage
            }
        }
    }
    
    
    private func updateTextBox() {
        if let editingTextEntity = selectedEntity as? TextBoxEntity {
            let uiColor = UIColor(backgroundColorUI)
            let cgColor = uiColor.cgColor
            
            editingTextEntity.updateText(textInput, font: selectedFont, size: fontSize, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined, textColor: textColor, backgroundColor: cgColor)
        }
    }
    
    private func sendEntityUpdate(_ entity: Entity) async {
        print("sending new entity")
        var text: String? = nil
        var imageURL: String? = nil

        if let textEntity = entity as? TextBoxEntity {
            text = textEntity.getText()
        } else if let imageEntity = entity as? FramedImageEntity  {
            imageURL = await fbVM.convertImageToURL(image: imageEntity.image)
        }
        
        let entityUpdate = ScrapbookEntry(
            id: UUID(),
            name: entity.name,
            type: entity is TextBoxEntity ? "text" : "image",
            position: [entity.position.x, entity.position.y, entity.position.z],
            scale: entity.scale.x,
            rotation: [entity.transform.rotation.vector.x, entity.transform.rotation.vector.y, entity.transform.rotation.vector.z, entity.transform.rotation.vector.w],
            text: text,
            imageURL: imageURL
        )

        if let data = try? JSONEncoder().encode(entityUpdate) {
            multipeerSession.sendToAllPeers(data, reliably: true)
        }
    }

    private func compressImage(_ image: UIImage, compressionQuality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }


    private func updateEntity(with update: ScrapbookEntry) {
        if let existingEntity = anchor?.children.first(where: { $0.name == update.name }) {
            // Update existing entity
            existingEntity.position = SIMD3<Float>(x: update.position[0], y: update.position[1], z: update.position[2])
            existingEntity.scale = SIMD3<Float>(repeating: Float(update.scale))
            
            let rotation = simd_quatf(ix: update.rotation[0], iy: update.rotation[1], iz: update.rotation[2], r: update.rotation[3])
            existingEntity.transform.rotation = rotation

            if let textEntity = existingEntity as? TextBoxEntity, let text = update.text {
                textEntity.updateText(text, font: update.font, size: CGFloat(update.fontSize), isBold: update.isBold, isItalic: update.isItalic, isUnderlined: false, textColor: Color(red: Double(update.textColor[0]), green: Double(update.textColor[1]), blue: Double(update.textColor[2])), backgroundColor: CGColor(red: Double(update.backgroundColor[0]), green: Double(update.backgroundColor[1]), blue: Double(update.backgroundColor[2]), alpha: 1.0))
            }

        } else {
            Task {
                if update.type == "text", let text = update.text {
                    // Create a new text box
                    print("made new textbox")
                    let newTextbox = await TextBoxEntity(text: text)
                    newTextbox.name = update.name
                    newTextbox.position = SIMD3<Float>(x: update.position[0], y: update.position[1], z: update.position[2])
                    newTextbox.scale = SIMD3<Float>(repeating: Float(update.scale))
                    let rotation = simd_quatf(ix: update.rotation[0], iy: update.rotation[1], iz: update.rotation[2], r: update.rotation[3])
                    newTextbox.transform.rotation = rotation

                    entityPos.append(.zero)
                    counter += 1


                    DispatchQueue.main.async {
                        self.anchor?.addChild(newTextbox)
                    }
                } else if update.type == "image", let imageData = update.imageURL, let uiImage = await fbVM.getImageFromURL(urlString: imageData) {
                    // Create a new image entity
                    print("transfer here")
                    let newImage = await FramedImageEntity(image: uiImage, frameType: FrameType.classic)
                    newImage.name = update.name
                    newImage.position = SIMD3<Float>(x: update.position[0], y: update.position[1], z: update.position[2])
                    newImage.scale = SIMD3<Float>(repeating: Float(update.scale))
                    let rotation = simd_quatf(ix: update.rotation[0], iy: update.rotation[1], iz: update.rotation[2], r: update.rotation[3])
                    newImage.transform.rotation = rotation

                    entityPos.append(.zero)
                    counter += 1

                    DispatchQueue.main.async {
                        self.anchor?.addChild(newImage)
                    }
                }
            }
        }
    }
    
    func colorToFloatArray(_ color: Color) -> [Float] {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [Float(red), Float(green), Float(blue)]
    }
    
    func cgColorToFloatArray(_ color: CGColor) -> [Float] {
        // Convert the color to a compatible RGB color space
        guard let rgbColor = color.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let components = rgbColor.components else {
            return [0, 0, 0, 1]
        }

        // Handle both RGB and RGBA (e.g., RGB = 3 components, RGBA = 4 components)
        if components.count == 4 {
            return components.map { Float($0) }
        } else if components.count == 3 {
            return components.map { Float($0) } + [1.0] // Assume alpha = 1.0
        } else {
            return [0, 0, 0, 1]
        }
    }
    
    func updateCollisionShape(for entity: Entity, scale: Float) {
        // Create new appropriately sized collision component
        if let textEntity = entity as? TextBoxEntity {
            let scaledWidth = Float(textEntity.textComponent.size.width) * scale
            let scaledHeight = Float(textEntity.textComponent.size.height) * scale
            textEntity.textEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [ShapeResource.generateBox(width: scaledWidth, height: scaledHeight, depth: 0.05)])
        } else if let framedImage = entity as? FramedImageEntity {
            // Similar logic for framed images
            let scaledWidth = Float(framedImage.image.size.width) * scale
            let scaledHeight = Float(framedImage.image.size.height) * scale
            framedImage.imageEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [ShapeResource.generateBox(width: scaledWidth, height: scaledHeight, depth: 0.05)])
        }
    }
}

// This is to make the color picker appear more seamlessly when you change text or background color in a textbox
extension UIColorWell {
    override open func didMoveToSuperview() {
        if let uiButton = self.subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> ())?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
