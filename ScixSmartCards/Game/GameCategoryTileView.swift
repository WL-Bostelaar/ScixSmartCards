//
//  GameCategoryTileView.swift
//  FlashCards
//
//  Created by William Bostelaar on 9/6/2024.
//

import SwiftUI
import SwiftData

struct GameCategoryTileView: View {
    var category: String
    @Query private var decks: [Deck]
    
    var body: some View {
        NavigationLink(destination: GameView(decks: decks.filter { $0.category == category })) {
            HStack{
                Text("All \(category)")
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .padding()
                    .foregroundStyle(Color("Text"))
                
                Spacer()
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color("Overlay"), Color("Overlay")]), startPoint: .top, endPoint: .bottom))
            .frame(maxWidth: .infinity, minHeight: 30)
            .cornerRadius(15)        }
    }
}
