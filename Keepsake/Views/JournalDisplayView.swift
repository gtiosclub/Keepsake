//
//  JournalDisplayView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import SwiftUI

struct JournalDisplayView: View {
    @Binding var displayIsHidden: Bool
    @ObservedObject var userVM: UserViewModel
    @State var shelfIndex: Int
    @State var bookIndex: Int
    @Binding var displayPageIndex: Int
    @Binding var zIndex: Double
    @Binding var displayDegrees: CGFloat
    @Binding var circleStart: CGFloat
    @Binding var circleEnd: CGFloat
    @Binding var frontIsHidden: Bool
    @Binding var frontDegrees: CGFloat
    @Binding var inTextEntry: Bool
    @State var scaleFactor: CGFloat = 1
    @Binding var selectedEntry: Int
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
                .zIndex(displayIsHidden ? 0 : zIndex)
                .foregroundStyle(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).template.pageColor)
                .offset(x: UIScreen.main.bounds.height * 0.002, y: 0)
            VStack {
                if displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 {
                    ForEach(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].entries.indices, id: \.self) { index in
                        JournalTextWidgetView(entry: userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].entries[index])
                            .padding(.top, 10)
                            .opacity(displayIsHidden ? 0 : 1)
                            .onTapGesture {
                                selectedEntry = index
                                inTextEntry.toggle()
                            }
                      
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(displayPageIndex < userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages.count && displayPageIndex > -1 ? "\(userVM.getJournal(shelfIndex: shelfIndex, bookIndex: bookIndex).pages[displayPageIndex].number)" : "no more pages")
                        .padding(.trailing, UIScreen.main.bounds.width * 0.025)
                }
            }
            
        }.frame(width: UIScreen.main.bounds.width * 0.87, height: UIScreen.main.bounds.height * 0.55)
            .rotation3DEffect(.degrees(displayDegrees), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint(x: UnitPoint.leading.x - 0.011, y: UnitPoint.leading.y), anchorZ: 0, perspective: 0.2)
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        if value.translation.width < 0 {
                            circleStart = 0.5
                            circleEnd = 1
                            zIndex = -0.5
                            withAnimation(.linear(duration: 0.5).delay(0.5)) {
                                displayDegrees -= 90
                                circleEnd -= 0.25
                            } completion: {
                                circleStart = 0.75
                                circleEnd = 1
                                displayIsHidden = true
                                withAnimation(.linear(duration: 0.5).delay(0)) {
                                    displayDegrees -= 90
                                    circleStart -= 0.25
                                } completion: {
                                    displayDegrees = 0
                                    displayPageIndex += 1
                                    displayIsHidden = false
                                }
                            }
                        }
                        
                        if value.translation.width > 0 {
                            // right
                            circleStart = 0.5
                            circleEnd = 1
                            withAnimation(.linear(duration: 0.5).delay(0.5)) {
                                frontDegrees += 90
                                circleStart += 0.25
                            } completion: {
                                frontIsHidden = false
                                circleStart = 0.5
                                circleEnd = 0.75
                                withAnimation(.linear(duration: 0.5).delay(0)) {
                                    frontDegrees += 90
                                    circleEnd += 0.25
                                } completion: {
                                    displayPageIndex -= 1
                                    frontDegrees = -180
                                    frontIsHidden = true
                                }
                            }
                        }
                    })
            )
    }
}


