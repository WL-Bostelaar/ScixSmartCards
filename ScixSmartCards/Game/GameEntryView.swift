//
//  GameEntryView.swift
//  FlashCards
//
//  Created by William Bostelaar on 9/6/2024.
//

import SwiftUI
import SwiftData

struct GameEntryView: View {
    @Query public var decks: [Deck]
    @Environment(\.modelContext) private var modelContext  // Correct environment setup
    @State var topDecks: [Deck] = []
    @State private var usedColors: [DeckColor] = []
    
    var body: some View {
        if decks.isEmpty {
            VStack {
                Text("Create a deck to start studying")
            }
            .navigationTitle("Study")
        } else {
            ScrollView {
                //Todays Decks
                NavigationLink(destination: GameView(decks: topDecks)) {
                    ZStack {
                        Rectangle()
                            .fill(RadialGradient(colors: [Color("GradientBlue"), Color("GradientBlue2")], center: .center, startRadius: 0, endRadius: 300))
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                        
                        VStack {
                            Text("Today's Decks")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Text("Decks due for revision")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                ForEach(topDecks) { deck in
                                    Text(deck.name)
                                        .foregroundColor(Color.accentColor)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .padding(.horizontal, 4)
                                        .frame(minWidth: 60, maxWidth: 300, minHeight: 30, maxHeight: 30)
                                        .overlay( RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.accentColor,lineWidth: 2))
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
                //Categories (All Shuffled, Indiviual Decks)
                
                Text("All")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundStyle(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                ForEach(decks.map { $0.category }.unique(), id: \.self) { category in
                    GameCategoryTileView(category: category)
                    
                    VStack {
                        ForEach(decks.filter { $0.category == category }) { deck in
                            GameDeckTileView(deck: deck)
                        }
                    }
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(usedColors, id: \.self) { color in
                            let colorDecks = decks.filter { $0.deckColor == color }
                            NavigationLink(destination: GameView(decks: colorDecks)) {
                                ZStack {
                                    Image("GameColorBackground.png")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundStyle(Color(color.color))
                                        .background(Color("Overlay"))
                                        .frame(width: 200, height: 100, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text("\(color.displayName) Decks")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(Color("Text"))
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Study")
            .onAppear {
                updateAllDeckStatistics()
                findTopTwoDecks()
                updateUsedColors()
            }
            .scrollIndicators(.hidden)
        }
    }
    
    //update the learnfactor of every card on load of the game to determine which cards to be called in today's cards
    
    private func updateAllDeckStatistics() {
        for deck in decks {
            let statistics = CalculateDeckStatistics(for: deck)
            deck.statistics.append(statistics)
            print(statistics.deck?.name ?? "Nil")
            print(statistics.calculationDate)
            print(statistics.averageLearnFactor)
            print(statistics.daysStudied)
            print(statistics.averageCorrectAnswers)
        }
        try? modelContext.save()
    }
    
    private func findTopTwoDecks() {
        let sortedDecks = decks.sorted { deck1, deck2 in
            let avgLearnFactor1 = deck1.statistics.last?.averageLearnFactor ?? 0
            let avgLearnFactor2 = deck2.statistics.last?.averageLearnFactor ?? 0
            return avgLearnFactor1 > avgLearnFactor2
        }
        topDecks = Array(sortedDecks.prefix(2))
    }
    
    private func updateUsedColors() {
        let colors = decks.map { $0.deckColor }.filter { $0 != .nocolor }
        usedColors = Array(Set(colors))
    }
}
