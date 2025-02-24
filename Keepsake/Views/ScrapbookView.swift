import SwiftUI
import RealityKit

struct ScrapbookView: View {
    @State private var textBox: TextBoxEntity?
    @State private var textInput: String = "Hello World"
    @State private var position: UnitPoint = .zero
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(anchor)

                Task {
                    let newTextBox = await TextBoxEntity(text: textInput)
                    self.textBox = newTextBox
                    anchor.addChild(newTextBox)
                }
            }
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged {
                    if let textBox = textBox {
                        textBox.position.x = Float($0.translation.width + position.x) * 0.002
                        textBox.position.y = Float($0.translation.height + position.y) * -0.002
                    }
                }
                .onEnded {
                    position.x += $0.translation.width
                    position.y += $0.translation.height
                })

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
                        }

                    Button("Done") {
                        updateTextBox()
                        isEditing = false
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
        .onTapGesture {
            isEditing.toggle()
        }
    }

    private func updateTextBox() {
        textBox?.updateText(textInput)
    }
}

