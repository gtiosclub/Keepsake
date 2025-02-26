import SwiftUI
import RealityKit

struct TextBoxData: Identifiable {
    var id = UUID()
    var text: String
    var position: SIMD3<Float>
    var entity: TextBoxEntity?
}

struct ScrapbookView: View {
    @State private var textBoxes: [TextBoxData] = []
    @State private var textInput: String = ""
    @State private var dragPosition: UnitPoint = .zero
    @State private var editingTextBoxId: UUID? = nil
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(anchor)
                
                // Initial text box if none exist
                if textBoxes.isEmpty {
                    Task {
                        let initialText = "Welcome to Scrapbook"
                        let newTextBox = await TextBoxEntity(text: initialText)
                        let initialPosition = SIMD3<Float>(x: 0, y: 0, z: 0)
                        let newBoxData = TextBoxData(text: initialText, position: initialPosition, entity: newTextBox)
                        
                        // We need to update the state on the main thread
                        await MainActor.run {
                            textBoxes.append(newBoxData)
                        }
                        
                        anchor.addChild(newTextBox)
                    }
                }
                
                // Add any new text boxes that don't have entities yet
                for index in textBoxes.indices {
                    if textBoxes[index].entity == nil {
                        Task {
                            let newTextBox = await TextBoxEntity(text: textBoxes[index].text)
                            newTextBox.position = textBoxes[index].position
                            
                            await MainActor.run {
                                textBoxes[index].entity = newTextBox
                            }
                            
                            anchor.addChild(newTextBox)
                        }
                    }
                }
            } update: { content in
                // Handle updates to existing text boxes
                for textBoxData in textBoxes {
                    if let entity = textBoxData.entity {
                        entity.position = textBoxData.position
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
                            set: { textBoxes[index].text = $0 }
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
        .onTapGesture { location in
            // If already editing, save current changes and exit edit mode
            if editingTextBoxId != nil {
                if let index = textBoxes.firstIndex(where: { $0.id == editingTextBoxId }) {
                    updateTextBox(index: index)
                }
                editingTextBoxId = nil
                return
            }
            
            // Otherwise try to select a text box to edit based on location
            // This is simplified and would need hit-testing in a real app
            if !textBoxes.isEmpty && selectedTextBoxIndex != nil {
                editingTextBoxId = textBoxes[selectedTextBoxIndex!].id
            }
        }
    }
    
    // Computed property to get the index of the currently selected text box
    private var selectedTextBoxIndex: Int? {
        if let editingId = editingTextBoxId {
            return textBoxes.firstIndex(where: { $0.id == editingId })
        }
        // For now, just use the first text box if none is selected
        return textBoxes.isEmpty ? nil : 0
    }
    
    private func addNewTextBox() {
        let newText = "New Text Box"
        let newPosition = SIMD3<Float>(x: 0, y: Float(textBoxes.count) * 0.2, z: 0)
        let newBoxData = TextBoxData(text: newText, position: newPosition)
        textBoxes.append(newBoxData)
    }
    
    private func updateTextBox(index: Int) {
        if let entity = textBoxes[index].entity {
            entity.updateText(textBoxes[index].text)
        }
    }
}

