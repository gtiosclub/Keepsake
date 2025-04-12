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
    @State private var backgroundColor: Color = .white
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

    var body: some View {
        ZStack {
            ARView
                .ignoresSafeArea()
                .gesture(tapGesture)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
            
            VStack {
                Spacer()
                if isEditing {
                    TextEditView
                    Spacer()
                } else if isCustomizingImage {
                    ImageCustomizationView
                } else {
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
                            let entry = ScrapbookEntry(id: UUID(), type: "text", position: [textEntity.position.x, textEntity.position.y, textEntity.position.z], scale: textEntity.scale.x, rotation: [textEntity.transform.rotation.vector.x, textEntity.transform.rotation.vector.y, textEntity.transform.rotation.vector.z, textEntity.transform.rotation.vector.w], text: textEntity.getText(), imageURL: "nil")
                            
                            userVM.updateScrapbookEntry(scrapbook: scrapbook, pageNum: 0, newEntry: entry)
                        } else if let imageEntity = entity as? ImageEntity {
                            let url = await fbVM.convertImageToURL(image: imageEntity.image)
                        
                            
                            let entry = ScrapbookEntry(id: UUID(), type: "image", position: [imageEntity.position.x, imageEntity.position.y, imageEntity.position.z], scale: imageEntity.scale.x, rotation: [imageEntity.transform.rotation.vector.x, imageEntity.transform.rotation.vector.y, imageEntity.transform.rotation.vector.z, imageEntity.transform.rotation.vector.w], text: "", imageURL: url)
                            
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
                    entity = await TextBoxEntity(text: entry.text ?? "[Blank]")
                } else if entry.type == "image" {
                    entity = await ImageEntity(image: fbVM.getImageFromURL(urlString: entry.imageURL ?? "") ?? UIImage())
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
            
        } update: { content in
            // creates a new textbox when the button in toolbar is pressed
            if isTextClicked {
                Task {
                    let newTextbox = await TextBoxEntity(text: "[Enter text]")
                    newTextbox.name = "\(counter)"
                    entityPos.append(.zero)
                    counter += 1
                    self.anchor?.addChild(newTextbox)
                    
                }
            }
            // creates a new image when the button in toolbar is pressed
            if isImageClicked {
                Task {
                    if let validImage = currImage {
//                        let newImage = await FramedImageEntity(image: validImage, frameType: .polaroid)
                        var frameType = FrameType.classic
                        if polaroidFrameSelected {
                            frameType = FrameType.polaroid
                        }
                        let newImage = await FramedImageEntity(image: validImage, frameType: frameType)
                        newImage.name = "\(counter)"
                        entityPos.append(.zero)
                        counter += 1
                        self.anchor?.addChild(newImage)
                        
                        // MAKE SURE THIS ISNT BUGGY
                        noFrameSelected = true
                        polaroidFrameSelected = false
                        flowerFrameSelected = false
                        isImageClicked = false
                    } else {
                        print("No image loaded")
                    }
                }
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
                        isCustomizingImage = true
                        Task {
                            await loadImage()
                        }
//                        isImageClicked = true
                    }
        
                    Button {
                        isTextClicked = true
                        Task {
                            try await Task.sleep(nanoseconds: 10_000)
                            isTextClicked = false
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
                        isEditing = true
                        print("edit button pressed")
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
                        isImageClicked = true
                    } label: {
                        Text("Done")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(25)
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
                    ColorPicker("", selection: $backgroundColor, supportsOpacity: true)
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
                if let selected = value.hitTest(point: value.location, in: .local).first?.entity.parent {
                    if let previousSelected = selectedEntity as? TextBoxEntity{
                        previousSelected.setSelected(false)
                    } else if let previousSelected = selectedEntity as? FramedImageEntity{
                        previousSelected.setSelected(false)
                    }
                    selectedEntity = selected
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
                currentScale = finalScale * value
                selectedEntity?.scale = SIMD3<Float>(repeating: Float(currentScale))
            }
            .onEnded { value in
                finalScale = currentScale
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
            editingTextEntity.updateText(textInput, font: selectedFont, size: fontSize, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined, textColor: textColor, backgroundColor: backgroundColor)
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
