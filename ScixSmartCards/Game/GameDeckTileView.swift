//
//  GameDeckTileView.swift
//  FlashCards
//
//  Created by William Bostelaar on 9/6/2024.
//

import SwiftUI
import SwiftData

struct GameDeckTileView: View {
    var deck: Deck
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationLink(destination: GameView(decks: [deck])) {
            HStack {
                Text(deck.name)
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .padding()
                    .foregroundStyle(Color("Text"))
                
                Spacer()
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color("Overlay"), Color("Overlay")]), startPoint: .top, endPoint: .bottom))
            .frame(maxWidth: .infinity, minHeight: 30)
            .cornerRadius(15)
            .padding(.leading)
        }
    }
}
