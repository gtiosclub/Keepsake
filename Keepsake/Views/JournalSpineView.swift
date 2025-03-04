import SwiftUI

struct JournalSpine: View {
    @State var book: any Book
    @State var degrees: CGFloat
    
    var body: some View {
        ZStack {
            // Spine Background with slight curve
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [book.template.coverColor.opacity(0.9), book.template.coverColor.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.56)
                .shadow(radius: 5)
                .overlay(
                    Image("leather") // Load texture image from assets
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.56)
                        .scaledToFill()
                        .opacity(0.5) // Adjust for realism
                )
                .overlay(
                    VStack {
                        Spacer()
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.black.opacity(0.2))
                                .frame(width: UIScreen.main.bounds.width * 0.08, height: 2)
                        }
                        Spacer()
                    }
                )
            
            // Book Title on Spine with Embossing Effect
            Text(book.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(book.template.titleColor)
                .rotationEffect(.degrees(-90)) // Rotate text for vertical alignment
                .frame(width: UIScreen.main.bounds.height * 0.5)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 1, y: 1)
        }
    }
}

#Preview {
    JournalSpine(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: []), degrees: 0)
}
