//
//  SettingsView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cardStatistics: [CardStatistics]
    @Query private var deckStatistics: [DeckStatistics]
    @State private var showAlert = false
    @AppStorage("onboarded") var onboarded: Bool = false
    @Query private var cards: [Card]
    @State private var isShowingImportDeckView = false
    
    let scixType = UTType(exportedAs: "com.scix.deck", conformingTo: .data)

    var body: some View {
        Form {
            Section(header: Text("Share")) {
                Button(action: {
                                isShowingImportDeckView = true
                }) {
                    Text("Import Deck")
                }
                Text("Export decks to file")
                
            }

            
//            Section(header: Text("Subscription")) {
//                NavigationLink(destination: SubsStoreView()) {
//                    Text("Upgrade to premium")
//                }
//            }
            
            Section(header: Text("App Information")) {
                Text("Help")
                Text("Privacy Policy")
                Text("Disclaimer")
            }
            
            
            Section(header: Text("Dev")) {
                Text("Go back to onboarding")
                    .onTapGesture{
                        onboarded = false
                    }
                
                Text("Print number of cards")
                    .onTapGesture{
                        print(cards.count)
                    }
            }



            
            Section(header: Text("Delete Data")) {
                Text("Delete User Stats")
            }
            .onTapGesture {
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Statistics"),
                    message: Text("This will delete all statisics history, are you sure?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteStats()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(isPresented: $isShowingImportDeckView, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importDeck(result: url)
                }
            case .failure(let error):
                print("Failed to import file: \(error.localizedDescription)")
            }
        }

    }
    
    private func deleteStats() {
        do {
            try modelContext.delete(model: CardStatistics.self)
        } catch {
            print("Failed to delete CardStatistics.")
        }
        do {
            try modelContext.delete(model: DeckStatistics.self)
        } catch {
            print("Failed to delete DeckStatistics.")
        }
        do {
            try modelContext.delete(model: PlaythroughStats.self)
        } catch {
            print("Failed to delete PlaythroughStats.")
        }
    }
    
    func importDeck(result: URL) {
        do {
            let data = try Data(contentsOf: result)
            let exportableDeck = try JSONDecoder().decode(ExportableDeck.self, from: data)
            
            let deck = Deck(name: exportableDeck.name, category: exportableDeck.category)
        
            modelContext.insert(deck)
            
            for exportableCard in exportableDeck.cards {
                let card = Card(
                    questiontype: exportableCard.questiontype,
                    question: exportableCard.question,
                    answer: exportableCard.answer,
                    wronganswers: exportableCard.wronganswers,
                    imageData: exportableCard.imageData,
                    learnfactor: exportableCard.difficulty,
                    difficulty: Int(exportableCard.difficulty)
                )
                modelContext.insert(card)
                deck.cards.append(card)
            }
            
            try modelContext.save()
            
        } catch {
            print(error)
        }
    }
}


