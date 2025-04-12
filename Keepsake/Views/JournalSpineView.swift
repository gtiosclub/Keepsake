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
                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.56)
                .shadow(radius: 5)
//                .overlay(
//                    Image("leather") // Load texture image from assets
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.56)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .scaledToFill()
//                        .opacity(0.5) // Adjust for realism
//                )
                .overlay(
                    VStack(spacing: UIScreen.main.bounds.height * 0.45) { // Space them more
                        ForEach(0..<2) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [
                                        book.template.coverColor.opacity(0.4), // Darker base
                                        book.template.coverColor.opacity(0.2),
                                        Color.white.opacity(0.1) // Highlighted top
                                    ]), startPoint: .top, endPoint: .bottom)
                                ).brightness(-0.5)
                                .frame(width: UIScreen.main.bounds.width * 0.4, height: 8)
                                .shadow(color: Color.black.opacity(0.5), radius: 1, x: 1, y: 1) // Depth shadow
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5) // Highlight for embossing
                                )
                        }
                    }
                )
            
            // Book Title on Spine with Embossing Effect
            Text(book.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(book.template.titleColor)
                .rotationEffect(.degrees(-90)) // Rotate text for vertical alignment
                .frame(width: UIScreen.main.bounds.height * 0.5)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 1, y: 1)
                .overlay(
                        Text(book.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .rotationEffect(.degrees(-90))
                            .offset(x: -1, y: -1) // Subtle highlight
                            .blur(radius: 0.5)
                )
        }
    }
}

#Preview {
    JournalSpine(book: Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: [], currentPage: 2), degrees: 0)
}
