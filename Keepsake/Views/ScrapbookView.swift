import SwiftUI
import RealityKit

struct ScrapbookView: View {
//    @State private var textBox: TextBoxEntity?
//    @State private var textInput: String = "Hello World"
//    @State private var isEditing: Bool = false
    @State private var textBoxes: [TextBoxEntity] = []
    @State private var textInputs: [String] = []
    
    // @State private var position: UnitPoint = .zero
    @State private var selectedTextIndex: Int? = nil
    @State private var positions: [SIMD3<Float>] = []
    
    
    @State private var isAddingTextBox = false
    @State private var newTextInput = ""
    
    @State private var anchor: AnchorEntity?

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                let anchorEntity = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(anchorEntity)
                
                DispatchQueue.main.async {
                    self.anchor = anchorEntity
                }
                
                //                Task {
                //                    //                    let newTextBox = await TextBoxEntity(text: textInput)
                //                    //                    self.textBox = newTextBox
                //                    //                    anchor.addChild(newTextBox)
                //                    for text in textInputs {
                //                        let newTextBox = await TextBoxEntity(text: text)
                //                        self.textBoxes.append(newTextBox)
                //                        anchor.addChild(newTextBox)
                //                    }
                //                }
            }
            update: { content in
                for (index, entity) in textBoxes.enumerated() {
                    entity.position = positions[index] // Ensure position updates
                }
            }
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onChanged { gesture in
                    guard let selectedIndex = selectedTextIndex else { return }
                    
                    // Convert drag gesture into 3D position change
                    let newPosition = SIMD3<Float>(
                        x: positions[selectedIndex].x + Float(gesture.translation.width) * 0.002,
                        y: positions[selectedIndex].y - Float(gesture.translation.height) * 0.002,
                        z: positions[selectedIndex].z
                    )
                    
                    positions[selectedIndex] = newPosition
                }
                .onEnded { gesture in
                    guard let selectedIndex = selectedTextIndex else { return }
                    
                    // Finalize position update
                    positions[selectedIndex].x += Float(gesture.translation.width) * 0.002
                    positions[selectedIndex].y -= Float(gesture.translation.height) * 0.002
                })
            VStack {
                Button("Add Text Box") {
                    isAddingTextBox = true  // Show pop-up
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                    
//                    if let selectedIndex = selectedTextIndex {
//                        TextField("Edit Text", text: $textInputs[selectedIndex])
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding()
//                            .background(Color.white.opacity(0.8))
//                            .cornerRadius(10)
//                            .onSubmit {
//                                updateTextBox(at: selectedIndex)
//                            }
//                    }
            }
            // WORKING CODE FOR EDITING TEXT BOX (SINGLE):
                //            if isEditing {
                //                VStack {
                //                    TextField("Edit Text", text: $textInput)
                //                        .textFieldStyle(RoundedBorderTextFieldStyle())
                //                        .padding()
                //                        .background(Color.white.opacity(0.8))
                //                        .cornerRadius(10)
                //                        .onSubmit {
                //                            updateTextBox()
                //                            isEditing = false
                //                        }
                //
                //                    Button("Done") {
                //                        updateTextBox()
                //                        isEditing = false
                //                    }
                //                    .padding()
                //                    .background(Color.blue)
                //                    .foregroundColor(.white)
                //                    .cornerRadius(10)
                //                }
                //                .frame(maxWidth: 250)
                //                .background(Color.black.opacity(0.6))
                //                .cornerRadius(15)
                //                .padding()
                //            }
        }
            .onTapGesture {
                //isEditing.toggle()
                selectedTextIndex = nil
            }
            .alert("Enter Text", isPresented: $isAddingTextBox) {
                        TextField("Text Box Content", text: $newTextInput)
                        Button("Cancel", role: .cancel) { isAddingTextBox = false }
                        Button("Add") { addTextBox() }
            }
    }
    
    private func addTextBox() {
        Task {
            guard !newTextInput.isEmpty, let anchor = anchor else { return }
            
            let newPosition = SIMD3<Float>(x: 0, y: 0, z: -2 - Float(textBoxes.count) * 0.2)
            let newTextBox = await TextBoxEntity(text: newTextInput)
            newTextBox.position = newPosition

            DispatchQueue.main.async {
                textBoxes.append(newTextBox)
                textInputs.append(newTextInput)
                positions.append(newPosition)
                anchor.addChild(newTextBox)
                newTextInput = ""
                isAddingTextBox = false
            }
        }
    }

    private func updateTextBox(at index: Int) {
        textBoxes[index].updateText(textInputs[index])
        //textBox?.updateText(textInput)
    }
}

