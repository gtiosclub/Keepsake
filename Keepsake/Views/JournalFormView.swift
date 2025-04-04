import SwiftUI

struct JournalFormView: View {
    @Binding var isPresented: Bool
    var onCreate: (String, Color, Color, Color, Texture, [JournalPage]?) -> Void
    var templates: [Template]
    
    @State private var title: String = ""
    @State private var coverColor: Color = .blue
    @State private var pageColor: Color = .white
    @State private var titleColor: Color = .black
    @State private var selectedTemplate: Template? = nil
    @State private var selectedTexture: Texture = .leather
    @State private var journalPages: [JournalPage]? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journal Details")) {
                    TextField("Journal Title", text: $title)
                    
                    if selectedTemplate == nil {
                        ColorPicker("Cover Color", selection: $coverColor)
                        ColorPicker("Page Color", selection: $pageColor)
                        ColorPicker("Title Color", selection: $titleColor)
                        // Create a drop down for the texture enums
                        
                        Picker("Cover Texture", selection: $selectedTexture) {
                            ForEach(Texture.allCases, id: \.self) { texture in
                                Text(texture.rawValue.capitalized).tag(texture)
                            }
                        }
                    }
                }
                
                Section(header: Text("Or Choose a Template")) {
                    ForEach(templates, id: \.name) { template in
                        Button(action: {
                            selectTemplate(template)
                        }) {
                            HStack {
                                Text(template.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedTemplate?.name == template.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    if selectedTemplate != nil {
                        Button("Clear Selection") {
                            selectedTemplate = nil
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Journal")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Create") {
                    if let selected = selectedTemplate {
                        onCreate(title.isEmpty ? selected.name : title,
                                 selected.coverColor,
                                 selected.pageColor,
                                 selected.titleColor,
                                 selected.texture,
                                 selected.journalPages)
                    } else {
                        onCreate(title, coverColor, pageColor, titleColor, selectedTexture, nil)
                    }
                    isPresented = false
                }
                    .disabled(title.isEmpty && selectedTemplate == nil)
            )
        }
    }
    
    private func selectTemplate(_ template: Template) {
        selectedTemplate = template
        coverColor = template.coverColor
        pageColor = template.pageColor
        titleColor = template.titleColor
        selectedTexture = template.texture
        journalPages = template.journalPages
    }
}


struct JournalFormView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTemplates = [
            Template(
                name: "Classic",
                coverColor: .blue,
                pageColor: .white,
                titleColor: .black,
                texture: .leather,
                journalPages: [
                    JournalPage(number: 1),
                    JournalPage(number: 2),
                    JournalPage(number: 3),
                    JournalPage(number: 4),
                    JournalPage(number: 5)
                ]
            ),
            Template(
                name: "Modern",
                coverColor: .gray,
                pageColor: .white,
                titleColor: .blue,
                texture: .blackLeather,
                journalPages: [
                    JournalPage(number: 1),
                    JournalPage(number: 2),
                    JournalPage(number: 3)
                ]
            )
        ]
        
        JournalFormView(
            isPresented: .constant(true),
            onCreate: { title, coverColor, pageColor, titleColor, texture, journalPages in
                print("Creating journal: \(title)")
            },
            templates: sampleTemplates
        )
    }
}
