//
//  DeckView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct DeckView: View {
    @Query public var decks: [Deck]
    @State private var showingAddDeckView = false
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var deckLoadingState: DeckLoadingState
        
    var body: some View {
        ScrollView {
            VStack {
                ForEach(decks.map { $0.category }.unique(), id: \.self) { category in
                    VStack(alignment: .leading) {
                        Text(category)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color("Text"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top) {
                                ForEach(decks.filter { $0.category == category }) { deck in
                                    DeckTileView(deck: deck)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            Button(action: {
                showingAddDeckView = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(Color("Overlay"))
                    .foregroundColor(Color("Text").opacity(0.6))
                    .clipShape(Circle())
            }
            .padding()
        }
        .padding()
        .navigationTitle("Your Decks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
            }
            
        }
        .sheet(isPresented: $showingAddDeckView) {
            AddDeckView()
        }
    }
}


extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return self.filter { seen.insert($0).inserted }
    }
}
