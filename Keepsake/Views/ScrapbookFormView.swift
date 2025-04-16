import SwiftUI

struct ScrapbookFormView: View {
    @Binding var isPresented: Bool
    var onCreate: (String, Color, Color, Color, Texture, [JournalPage]?) -> Void
    var templates: [Template]
    
    @State private var title: String = ""
    @State private var coverColor: Color = Color(red: 1.0, green: 0.7686, blue: 0.7294)
    @State var colorArr: [Double] = [1.0, 0.7686, 0.7294]
    @State private var pageColor: Color = .white
    @State private var selectedTemplate: Template? = nil
    @State private var selectedTexture: Texture = .leather
    @State private var journalPages: [JournalPage]? = nil
    @State private var selectedTab: String = "cover"
    @State private var showOnlyCover: Bool = false
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var fbVM: FirebaseViewModel
    
    
    let journalWidth = UIScreen.main.bounds.width * 0.92 * 0.5
    let journalHeight = UIScreen.main.bounds.height * 0.56 * 0.5
    
    // color options
    let colorOptions: [(name: String, color: Color, colorArr: [Double])] = [
        ("Red", Color(red: 1.0, green: 0.7686, blue: 0.7294), [1.0, 0.7686, 0.7294]),
        ("Orange", Color(red: 1.0, green: 0.8392, blue: 0.7020), [1.0, 0.8392, 0.7020]),
        ("Yellow", Color(red: 1.0, green: 0.9804, blue: 0.6667), [1.0, 0.9804, 0.6667]),
        ("Green", Color(red: 0.8667, green: 0.9294, blue: 0.6667), [0.8667, 0.9294, 0.6667]),
        ("Blue", Color(red: 0.7059, green: 0.8667, blue: 0.949), [0.7059, 0.8667, 0.949]),
        ("Purple", Color(red: 0.8, green: 0.7765, blue: 0.9765), [0.8, 0.7765, 0.9765])
    ]
    
    //Fake variables because Alec sucks at coding
    @State var inEntry: EntryType = .openJournal
    @State var selectedEntry: Int = 0
    @State var showDeleteButton: Int = -1
    @State var frontDegrees: CGFloat = -180
    @State var isWiggling: Bool = false
    @State var deletePage: Int = -1
    @State var pageWiggling: Bool = false
    @State var journal: Journal = Journal()
    
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
                        onCreate(title, coverColor, pageColor, .black, selectedTexture, nil)
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
                                    name: title.isEmpty ? "Untitled" : title,
                                    coverColor: coverColor,
                                    pageColor: .white,
                                    titleColor: .black,
                                    texture: selectedTexture
                                ),
                                degrees: 0,
                                title: title.isEmpty ? "Untitled" : title, showOnlyCover: $showOnlyCover, offset: false
                            )
                            .id("\(coverColor)\(title) \(selectedTexture)")
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
                
                
            }
            .padding()
            .animation(.easeInOut, value: selectedTab)
            
            if selectedTab == "cover" {
                // FORM
                Form {
                    // FORM FIELDS
                    Section {
                        TextField("Scrapbook Title", text: $title)
                        
                        if selectedTemplate == nil {
                            Picker("Cover Color", selection: $coverColor) {
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
                                                showOnlyCover: $showOnlyCover,
                                                offset: false
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
        }.onChange(of: coverColor) { newColor in
            // Match the newColor with one in colorOptions
            if let match = colorOptions.first(where: { $0.color == newColor }) {
                colorArr = match.colorArr
            } else {
                // fallback if not found
                colorArr = [0.5, 0.5, 0.5]
            }
        }
    }
    
    private func selectTemplate(_ template: Template) {
        selectedTemplate = template
        coverColor = template.coverColor
        pageColor = template.pageColor
        selectedTexture = template.texture
        journalPages = template.journalPages
        title = template.name
    }
}
struct ScrapbookFormView_Previews: PreviewProvider {
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
                texture: .leather,
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
                texture: .leather,
                journalPages: [
                    JournalPage(number: 1),
                    JournalPage(number: 2),
                    JournalPage(number: 3)
                ]
            )
            
        ]
        
        ScrapbookFormView(
            isPresented: .constant(true),
            onCreate: { title, coverColor, pageColor, titleColor, texture, journalPages in
                print("Creating journal: \(title)")
            },
            templates: sampleTemplates, userVM: UserViewModel(user: User()), fbVM: FirebaseViewModel()
        )
    }
}
