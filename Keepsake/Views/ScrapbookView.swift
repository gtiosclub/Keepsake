import SwiftUI
import RealityKit

struct TextBoxData: Identifiable {
    var id = UUID()
    var text: String
    var position: SIMD3<Float>
    var entity: TextBoxEntity?
    var isNew: Bool = true  // Flag to track if this entity needs to be created
}

struct ScrapbookView: View {
    @State private var textBoxes: [TextBoxData] = []
    @State private var textInput: String = ""
    @State private var dragPosition: UnitPoint = .zero
    @State private var editingTextBoxId: UUID? = nil
    @State private var anchor: AnchorEntity? = nil
    @State private var selectedTextBoxId: UUID? = nil
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                
                // Create the anchor once
                let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                self.anchor = newAnchor
                content.add(newAnchor)
                
                // Initial text box if none exist
                if textBoxes.isEmpty {
                    Task {
                        let initialText = "Welcome to Scrapbook"
                        let newTextBox = await TextBoxEntity(text: initialText)
                        let initialPosition = SIMD3<Float>(x: 0, y: 0, z: 0)
                        
                        // We need to update the state on the main thread
                        await MainActor.run {
                            let newBoxData = TextBoxData(
                                text: initialText, 
                                position: initialPosition, 
                                entity: newTextBox,
                                isNew: false
                            )
                            textBoxes.append(newBoxData)
                        }
                        
                        newAnchor.addChild(newTextBox)
                    }
                }
            } update: { content in
                // Process any new text boxes that need to be created
                for index in textBoxes.indices {
                    if textBoxes[index].isNew {
                        Task {
                            let text = textBoxes[index].text
                            let position = textBoxes[index].position
                            
                            let newTextBox = await TextBoxEntity(text: text)
                            newTextBox.position = position
                            
                            // Set up tap handler for this entity
                            newTextBox.name = textBoxes[index].id.uuidString
                            
                            await MainActor.run {
                                // Update our data model with the created entity
                                textBoxes[index].entity = newTextBox
                                textBoxes[index].isNew = false
                            }
                            
                            // Add the new entity to the scene
                            if let anchor = self.anchor {
                                anchor.addChild(newTextBox)
                            }
                        }
                    } else if let entity = textBoxes[index].entity {
                        // Update position of existing entities
                        entity.position = textBoxes[index].position
                    }
                }
            }
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged { value in
                    guard let selectedIndex = selectedTextBoxIndex else { return }
                    guard let entity = textBoxes[selectedIndex].entity else { return }
                    
                    let translation = value.translation
                    entity.position.x = Float(translation.width + dragPosition.x) * 0.002
                    entity.position.y = Float(translation.height + dragPosition.y) * -0.002
                }
                .onEnded { value in
                    guard let selectedIndex = selectedTextBoxIndex else { return }
                    
                    dragPosition.x += value.translation.width
                    dragPosition.y += value.translation.height
                    
                    // Update the position in our data model
                    if let entity = textBoxes[selectedIndex].entity {
                        textBoxes[selectedIndex].position = entity.position
                    }
                })
            
            VStack {
                // Button to add new text box
                Button(action: addNewTextBox) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Text Box")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                // Text editing UI
                if let editingId = editingTextBoxId, 
                   let index = textBoxes.firstIndex(where: { $0.id == editingId }) {
                    VStack {
                        TextField("Edit Text", text: Binding(
                            get: { textBoxes[index].text },
                            set: { 
                                textBoxes[index].text = $0
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .onSubmit {
                            updateTextBox(index: index)
                            editingTextBoxId = nil
                        }
                        
                        Button("Done") {
                            updateTextBox(index: index)
                            editingTextBoxId = nil
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
            }
        }
        .onTapGesture(coordinateSpace: .global) { location in
            // If already editing, save current changes and exit edit mode
            if editingTextBoxId != nil {
                if let index = textBoxes.firstIndex(where: { $0.id == editingTextBoxId }) {
                    updateTextBox(index: index)
                }
                editingTextBoxId = nil
                return
            }
            
            // For direct selection, simulate selecting the text box based on tap location
            // In a full implementation, you would use proper hit testing here
            // For now, selecting any text box as a demonstration of the concept
            // This just cycles through the boxes since we can't do proper hit testing
            if !textBoxes.isEmpty {
                if let currentIndex = selectedTextBoxIndex {
                    let nextIndex = (currentIndex + 1) % textBoxes.count
                    selectedTextBoxId = textBoxes[nextIndex].id
                } else {
                    selectedTextBoxId = textBoxes[0].id
                }
                
                // For demonstration, immediately start editing the selected box
                editingTextBoxId = selectedTextBoxId
                dragPosition = .zero
            }
        }
    }
    
    // Computed property to get the index of the currently selected text box
    private var selectedTextBoxIndex: Int? {
        if let editingId = editingTextBoxId {
            return textBoxes.firstIndex(where: { $0.id == editingId })
        }
        if let selectedId = selectedTextBoxId {
            return textBoxes.firstIndex(where: { $0.id == selectedId })
        }
        return nil
    }
    
    private func addNewTextBox() {
        let newText = "New Text Box"
        
        // Position the new text box in the center of the current view
        // In RealityKit, we'd typically use the camera/view transform to determine this
        // For now, using a simplified approach with a slight random offset
        // to better simulate placing them in the center of where the user is looking
        let randomOffset = Float.random(in: -0.2...0.2)
        let newPosition = SIMD3<Float>(
            x: randomOffset,
            y: randomOffset,
            z: -0.5  // Slightly in front of the camera
        )
        
        // Create a new text box data with isNew = true
        let newBoxData = TextBoxData(
            text: newText, 
            position: newPosition,
            isNew: true
        )
        
        // Add it to our array - the update closure will create the actual entity
        textBoxes.append(newBoxData)
        
        // Automatically select and edit the new text box
        selectedTextBoxId = newBoxData.id
        editingTextBoxId = newBoxData.id
    }
    
    private func updateTextBox(index: Int) {
        if let entity = textBoxes[index].entity {
            entity.updateText(textBoxes[index].text)
        }
    }
}

