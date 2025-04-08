//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit
import PhotosUI

struct ScrapbookView: View {
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
    let fontSizes: [CGFloat] = Array(stride(from: 100, to: 300, by: 10))
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var showTextColorPicker: Bool = false
    @State private var showBackgroundColorPicker: Bool = false
    let fontOptions = [
        "Helvetica",
        "Times New Roman",
        "Courier",
        "Comic Sans",
        "Arial",
        "Impact",
        "Lato",
        "Oswald",
    ]



    var body: some View {
        ZStack {
            // RealityKit View
            RealityView { content in
                content.camera = .spatialTracking
                
                // creates new anchor and makes that "global" anchor
                let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                self.anchor = newAnchor
                content.add(newAnchor)

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
                        await loadImage()
                        if let validImage = currImage {
                            let newImage = await ImageEntity(image: validImage)
                            newImage.name = "\(counter)"
                            entityPos.append(.zero)
                            counter += 1
                            self.anchor?.addChild(newImage)
                            isImageClicked = false
                        } else {
                            print("No image loaded")
                        }
                    }
                }
            }
            // Tap gesture that changes the selectedEntity to the entity you click on
            .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity()
                .onEnded{ value in
                    /*
                     hitTest creates a ray at value.location and returns a list of CollisionCastHits that it encounters
                     We then use the first CollisionCastHit and get it's entity's parent
                     We get the parent instead of just the entity because
                     the entity will be the collsion shape attached to the entity instead of the entity itself
                     */
                    if let selected = value.hitTest(point: value.location, in: .local).first?.entity.parent {
                        selectedEntity = selected
                    }
                    print(selectedEntity?.name ?? "No Entity Selected")
                })

            // drag gesture to move the entities around in a sphere-like shape
            // gets change in 2D drag distance and converts that into 3D transformations
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
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
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = finalScale * value
                        selectedEntity?.scale = SIMD3<Float>(repeating: Float(currentScale))
                    }
                    .onEnded { value in
                        finalScale = currentScale
                    }
            )

            VStack {
                Spacer()
                if isEditing {
                    VStack (spacing: 16) {
                        // Place to input new/updated text
                        TextField("Edit Text", text: $textInput)
                            .padding()
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3)))
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            // Menu for updating font family
                            Menu {
                                ForEach(fontOptions, id: \.self) { font in
                                    Button(font) {
                                        selectedFont = font
                                    }
                                }
                            } label: {
                                Text(selectedFont)
                                    .frame(minWidth: 80)
                                    .padding()
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(12)
                            }

                            // Menu for updating font size
                            Menu {
                                ForEach(fontSizes, id: \.self) { size in
                                    Button("\(Int(size))") {
                                        fontSize = size
                                    }
                                }
                            } label: {
                                Text("\(Int(fontSize))")
                                    .frame(minWidth: 50)
                                    .padding()
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Font Styling Buttons
                        HStack(spacing: 20) {
                            Toggle(isOn: $isBold) {
                                Text("B").bold()
                            }
                            .toggleStyle(.button)

                            Toggle(isOn: $isItalic) {
                                Text("I").italic()
                            }
                            .toggleStyle(.button)

                            Toggle(isOn: $isUnderlined) {
                                Text("U").underline()
                            }
                            .toggleStyle(.button)
                        }
                        
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
                        
                        // Text Color & Background Buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                showTextColorPicker.toggle()
                            }) {
                                Text("text color")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.6))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                showBackgroundColorPicker.toggle()
                            }) {
                                Text("background")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.pink.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Pop-Up for editing text color
                        if showTextColorPicker {
                            ColorPicker("Select Text Color", selection: $textColor)
                                .padding(.horizontal)
                        }
                        // Pop-Up for editing background color
                        if showBackgroundColorPicker {
                            ColorPicker("Select Background Color", selection: $backgroundColor)
                                .padding(.horizontal)
                        }

                        
                        Button("Done") {
                            updateTextBox()
                            isEditing = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.top)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .shadow(radius: 10)
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
                        // this is what makes the ImageEntity created in the update closure of RealityView
                        isImageClicked = true
                    }
                    Spacer()
                    Button {
                        // this is what makes the TextBoxEntity created in the update closure of RealityView
                        isTextClicked = true
                        
                        // essentially toggles isTextClicked very fast, theres probably a more elegent way to do this
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
//                        RoundedRectangle(cornerRadius: 10.0)
//                            .frame(width: 80, height: 40)
//                            .background(Color.white)
                        Button {
                            isEditing = true
                            print("pressed")
                        } label : {
                            Text("Edit \(selectedEntity?.name ?? "")")
//                                .foregroundStyle(.black)
                        }.disabled(selectedEntity == nil)
                    }
                }
                .padding()
                .frame(width: 250, height: 100)
                .background(Color.white.opacity(0.5)) // Semi-transparent background
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 20) // Lifted up slightly
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
            //editingTextEntity.updateText(textInput, font: selectedFont, size: fontSize, bgColor: backgroundColor, textColor: textColor)
            editingTextEntity.updateText(textInput, font: selectedFont, size: fontSize, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined, textColor: textColor, backgroundColor: backgroundColor)
        }
    }
}
