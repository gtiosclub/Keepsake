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
    @State private var selectedTab: String = "cover"
    @State private var showOnlyCover: Bool = false
    
    let journalWidth = UIScreen.main.bounds.width * 0.92 * 0.5
    let journalHeight = UIScreen.main.bounds.height * 0.56 * 0.5
    
    // color options
    let colorOptions: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Red", .red),
        ("Green", .green),
        ("Multicolor", .pink)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Create") {
                    if let selected = selectedTemplate {
                        onCreate(
                            title.isEmpty ? selected.name : title,
                            selected.coverColor,
                            selected.pageColor,
                            selected.titleColor,
                            selected.texture,
                            selected.journalPages
                        )
                    } else {
                        onCreate(title, coverColor, pageColor, titleColor, selectedTexture, nil)
                    }
                    isPresented = false
                }
                .disabled(title.isEmpty && selectedTemplate == nil)
                .foregroundColor(.blue)
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 20)
            
            // COVER + WIDGET SECTION
            HStack(alignment: .top, spacing: 10) {
                // COVER
                VStack(spacing: 0) {
                    ZStack (alignment: .top){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(selectedTab == "cover" ? 0.2 : 0.00))
                            .frame(width: 170, height: 213)
                        
                        VStack(spacing: 0) {
                            Text("COVER")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.top, 10)
                                .padding(.bottom, 7)
                            
                            JournalCover(
                                template: Template(
                                    name: title.isEmpty ? "Untitled Journal" : title,
                                    coverColor: coverColor,
                                    pageColor: .white,
                                    titleColor: titleColor,
                                    texture: selectedTexture
                                ),
                                degrees: 0,
                                title: title.isEmpty ? "Untitled Journal" : title, showOnlyCover: $showOnlyCover
                            )
                            .scaleEffect(0.5)
                            .frame(width: 120, height: 157)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                        .frame(width: 140, height: 213, alignment: .top)
                        
                        VStack {
                            Spacer()
                            
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: 60, height: 4)
                                .opacity(selectedTab == "cover" ? 1 : 0)
                        }
                        .frame(height: 213)
                    }
                    
                }
                .onTapGesture {
                    selectedTab = "cover"
                }
                
                // WIDGET
                VStack(spacing: 0) {
                    
                    ZStack (alignment: .top){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(selectedTab == "widgets" ? 0.2 : 0.00))
                            .frame(width: 170, height: 213)
                            .shadow(radius: 2)
                        
                        VStack(spacing: 25) {
                            Text("WIDGETS")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.top, 10)
                            
                            Image("WidgetView")
                                .frame(width: 120, height: 120)
                                .padding(.top, 5)
                        }
                        VStack {
                            Spacer()
                            
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: 60, height: 4)
                                .opacity(selectedTab == "widgets" ? 1: 0)
                            
                        }
                        .frame(height: 213)
                    }
                    
                }
                .onTapGesture {
                    selectedTab = "widgets"
                }
                
            }
            .padding()
            .animation(.easeInOut, value: selectedTab)
            
            if selectedTab == "cover" {
                // FORM
                Form {
                    // FORM FIELDS
                    Section {
                        TextField("Journal Title", text: $title)
                        
                        if selectedTemplate == nil {
                            Picker("Cover Color", selection: $coverColor) {
                                ForEach(colorOptions, id: \.name) { option in
                                    Text(option.name).tag(option.color)
                                }
                            }
                            
                            Picker("Title Color", selection: $titleColor) {
                                ForEach(colorOptions, id: \.name) { option in
                                    Text(option.name).tag(option.color)
                                }
                            }
                            
                            Picker("Cover Texture", selection: $selectedTexture) {
                                ForEach(Texture.allCases, id: \.self) { texture in
                                    Text(texture.rawValue.capitalized).tag(texture)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Or Choose a Template")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 25) {
                                ForEach(templates, id: \.name) { template in
                                    Button(action: {
                                        selectTemplate(template)
                                    }) {
                                        VStack {
                                            JournalCover(
                                                template: template,
                                                degrees: 0,
                                                title: template.name,
                                                showOnlyCover: $showOnlyCover
                                            )
                                            .frame(width: 120, height: 157)
                                            .scaleEffect(0.5)
                                            .clipped()
                                            .cornerRadius(12)
                                            .shadow(radius: 2)
                                            
                                            HStack(spacing: 4) {
                                                Text(template.name)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                                
                                                if selectedTemplate?.name == template.name {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if selectedTemplate != nil {
                            Button("Clear Selection") {
                                selectedTemplate = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                }
            }
            else if selectedTab == "widgets" {
                Form {
                    Section(header: Text("Color Schemes")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(["Red", "Green", "Blue", "Multicolor"], id: \.self) { scheme in
                                    VStack(spacing: 8) {
                                        Image("WidgetView")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(12)

                                        Text(scheme)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.leading, 15)
                                    .padding(.trailing, 15)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }

            }
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
