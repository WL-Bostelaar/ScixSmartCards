//
//  DeckTileView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct DeckTileView: View {
    @State private var showingOptions = false
    @State private var showingEditView = false
    var deck: Deck
    @Environment(\.modelContext) private var modelContext

    var body: some View {
            ZStack(alignment: .topLeading) {
                //MARK: Background
                deck.deckImage.image
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(deck.deckColor.color.opacity(0.3)))
                    .frame(width: 200, height: 150, alignment: .bottom)
                    .background(Color("Overlay"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                
                
                //MARK: Main Tile - Deck Name
                if !showingOptions {
                    NavigationLink(destination: CardListView(deck: deck)) {
                        ZStack(alignment: .topLeading) {
                            Text(deck.name)
                                .font(.system(size: 25, weight: .bold))
                                .minimumScaleFactor(0.5)
                                .lineLimit(3)
                                .foregroundStyle(Color("Text"))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .frame(width: 200, height: 150)
                                .cornerRadius(10)
                            
                            Button(action: {
                                withAnimation() {
                                    showingOptions.toggle()
                                }}) {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(width: 50, height: 50, alignment: .topLeading)
                                    .foregroundColor(Color("Text"))
                                    .zIndex(1)
                            }
                        }
                    }
                }

                //MARK: Options Buttons
                if showingOptions {
                    HStack {
                        Spacer()

                        Button(action: deleteDeck) {
                            Image(systemName: "trash.fill")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 60, height: 60)
                                .background(Color.red.opacity(0.5))
                                .foregroundColor(Color("Text"))
                                .clipShape(Circle())
                        }
                        Spacer()

                        Button(action: {
                            withAnimation(.spring()){
                                showingEditView = true
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.5))
                                .foregroundColor(Color("Text"))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .frame(width: 200, height: 150)
                    .background(Color("Overlay"))
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation() {
                            showingOptions.toggle()
                        }}
                    .transition(.blurReplace)
                }
                
                //MARK: Edit View
                if showingEditView {
                    EditDeckView(deck: deck, isPresented: $showingEditView)
                        .transition(.scale(0, anchor: .topLeading).combined(with: .blurReplace))
                        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
            }
            .padding(.bottom)
            .padding(.horizontal, 3)
    }

    private func deleteDeck() {
        modelContext.delete(deck)
    }
}


