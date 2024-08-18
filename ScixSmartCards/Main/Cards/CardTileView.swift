//
//  CardTileView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct CardTileView: View {
    @Environment(\.modelContext) private var context
    @State var card: Card
    
    //Cycle Views
    @State var cardview: CardViews = .collapsed
    
    //Drag Items
    @State var offset: CGFloat = 0
    @State var currentDragOffset: CGFloat = 0
    @State var deleteAction: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action:
                        {withAnimation(.spring())
                        {cardview = .editer}})  {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(Color.white.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: deleteCard) {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(Color.red.opacity(0.5))
                        .foregroundColor(Color.white.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                //Collapsed View
                if cardview == .collapsed {
                    CardCollapsedView(card: card)
                }
                else if cardview == .expanded {
                    CardExpandedView(card: card)
                }
                else if cardview == .editer {
                    EditCardView(card: card, cardview: $cardview)
                        .onAppear(perform: resetOffset)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(gradient: Gradient(colors: [Color("Overlay"), Color("Overlay") ]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(15)
            .padding(.horizontal)
            .offset(x: offset)
            .offset(x: currentDragOffset)
            .gesture(
                DragGesture()
                    .onChanged {value in
                        withAnimation(.spring()) {
                            currentDragOffset = value.translation.width
                        }
                    }
                    .onEnded {value in
                        withAnimation(.spring()) {
                            //Show Delete
                            if offset == 0 && currentDragOffset < -40 {
                                offset = -60
                                //Show Edit
                            } else if offset == 0 && currentDragOffset > 40 {
                                offset = 60
                            }
                            //Hide Delete
                            else if offset == -60 && currentDragOffset > 40 {
                                offset = 0
                            }
                            //Hide Edit
                            else if offset == 60 && currentDragOffset < 40 {
                                offset = 0
                            }
                            currentDragOffset = 0
                        }
                    }
            )
            .onTapGesture(perform: {
                withAnimation(.spring()) {
                    if cardview == .collapsed {
                        cardview = .expanded
                    }
                    else if cardview == .expanded {
                        cardview = .collapsed
                    }}
            })
        }// End of ZStack
    } // End of Body
    
    // Functions
    private func deleteCard() {
        context.delete(card)
        deleteAction()
    }
    private func resetOffset() {
        if offset == 60 {
            withAnimation(.spring()) {
                offset = 0
            }
        }
    }
    enum CardViews {
        case collapsed, expanded, editer
    }
}


