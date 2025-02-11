//
//  JournalCoverImage.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

import SwiftUI

//struct ShallowArc: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
//        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
//                          control: CGPoint(x: rect.midX, y: -1 * rect.maxY))
//        
//        return path
//
//    }
//}
//
//struct LeftSemi: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
//        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
//                          control: CGPoint(x: rect.minX, y:  rect.minY))
//        
//        return path
//
//    }
//}
//
//struct RightSemi: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY),
//                          control: CGPoint(x: rect.maxX, y:  rect.minY))
//        
//        return path
//
//    }
//}
//
//struct BottomLeftSemi: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
//                          control: CGPoint(x: rect.minX, y:  rect.maxY))
//        
//        return path
//
//    }
//}
//
//struct ConnectedArcs: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        let startX = rect.minX
//        let endX = rect.maxX
//        let midX = rect.midX
//        let midY = rect.midY
//        let topY = rect.minY
//        let bottomY = rect.maxY
//        
//        // Control points to adjust the curvature
//        let controlTopY = topY - (rect.height * 0.3)
//        let controlBottomY = bottomY + (rect.height * 0.2)
//        
//        // Move to starting point (left center)
//        path.move(to: CGPoint(x: endX, y: midY))
//        
//        // Top arc (left to right)
//        path.addQuadCurve(to: CGPoint(x: startX, y: midY),
//                          control: CGPoint(x: midX, y: controlTopY))
//        
//        // Bottom arc (right to left) - completing the loop
//        path.addQuadCurve(to: CGPoint(x: midX, y: rect.maxY),
//                          control: CGPoint(x: midX, y: controlBottomY))
//        
//        return path
//    }
//}

struct JournalAnimation: View {
    @State var degrees: Double = 0
    @State var isHidden: Bool = false
    @State var coverZIndex: Double = 2
    var body: some View {
        ZStack {
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        LeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                        BottomLeftSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                        
                    }
                    
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.25)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.5 + 8, height: UIScreen.main.bounds.height * 0.3)
                .foregroundStyle(Color(red: 0.96, green: 0.5, blue: 0.5))
                .offset(x: 4, y: 7)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.3)
                .foregroundStyle(Color(red: 0.96, green: 0.95, blue: 0.78))
                .offset(x: 5, y: 5)
            VStack {
                ForEach(0..<9, id: \.self) { i in
                    VStack(spacing: 0) {
                        RightSemi().stroke(Color.black, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                        BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                    }
                  
                    
                }
            }.offset(x: UIScreen.main.bounds.width * -0.24)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.3)
                    .foregroundStyle(Color(red: 0.96, green: 0.5, blue: 0.5))
                Text("Title")
                    .font(.title)
                    .opacity(isHidden ? 0 : 1)
                VStack {
                    ForEach(0..<9, id: \.self) { i in
                        VStack(spacing: 0) {
                            RightSemi().stroke(Color.black, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.01)
                            BottomLeftSemi().stroke(Color.clear, lineWidth: 2)
                                .frame(width: UIScreen.main.bounds.width * 0.02, height: UIScreen.main.bounds.height * 0.005)
                            
                        }
                      
                        
                    }
                }.offset(x: UIScreen.main.bounds.width * -0.24)
                    
            }.rotation3DEffect(.degrees(degrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
        }
        Button("Animate") {
            withAnimation(.linear(duration: 0.7).delay(0.01)) {
                if !isHidden {
                    self.degrees -= 90
                } else {
                    self.degrees += 90
                }
            } completion: {
                isHidden.toggle()
                coverZIndex = 0
                withAnimation(.linear(duration: 0.7).delay(0.01)) {
                    if isHidden {
                        self.degrees -= 90
                    } else {
                        self.degrees += 90
                    }
                }
            }
        }.padding(.top, 20)
    }
}

#Preview {
    JournalAnimation()
}




