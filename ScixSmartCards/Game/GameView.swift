//
//  GameView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct GameView: View {
    var decks: [Deck]
    @Environment(\.modelContext) private var modelContext
    @State private var orderedCards: [Card] = []
    @State private var currentCardIndex: Int = 0
    @State private var starttime = Date()
    @State private var correcttally: Int = 0
    @State private var timeTaken = TimeInterval()
    @State private var totalCards: Int = 0
    @State private var incorrecttally: Int = 0
    @State private var playthroughStats: PlaythroughStats?
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(height: 200)
            } else if currentCardIndex < orderedCards.count {
                let card = orderedCards[currentCardIndex]
                if card.questiontype == "QnA" {
                    QnAView(card: card, index: currentCardIndex, correcttally: $correcttally, incorrecttally: $incorrecttally, onAnswer: goToNextCard)
                        .id(card.id)
                } else if card.questiontype == "Multiple Choice" {
                    MultipleChoiceView(card: card, index: currentCardIndex, onAnswer: goToNextCard, correcttally: $correcttally, incorrecttally: $incorrecttally)
                        .id(card.id)
                } else if card.questiontype == "Recite" {
                    ReciteView(card: card, index: currentCardIndex, correcttally: $correcttally, incorrecttally: $incorrecttally, onAnswer: goToNextCard)
                    .id(card.id)
                }
            } else {
                if let stats = playthroughStats {
                    EndCardView(playthroughStats: stats)
                } else {
                    Text("Error: No playthrough statistics available.")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prepareCards()
            starttime = Date.now
        }
        .frame(maxWidth: 600)
    }

    private func prepareCards() {
        let allCards = decks.flatMap { $0.cards }
        orderedCards = allCards.sorted(by: { $0.learnfactor > $1.learnfactor })
        print("number of cards in loaded decks: \(orderedCards.count)")
        starttime = Date.now
        totalCards = allCards.count
        startStats()
        print("stats started")
        isLoading = false
    }

    private func goToNextCard() {
        if currentCardIndex < orderedCards.count {
            currentCardIndex += 1
            print("Moved to next card. Current card index: \(currentCardIndex)")
            updatePlaythroughStats()
            print("commenced stats")
        } else {
            completeDeck()
            print("completed stats")
        }
    }
    
    // Running Stats
    private func startStats() {
        let newplaythrough = PlaythroughStats(
            id: UUID(),
            dateplayed: Date(),
            deck: decks.first,
            totalCards: totalCards
        )
        modelContext.insert(newplaythrough)
        playthroughStats = newplaythrough
        print("date played:\(playthroughStats!.dateplayed) , deck: \(String(describing: playthroughStats!.deck)), totalcards: \(playthroughStats!.totalCards), correctcards: \(playthroughStats!.correctCards), incorrectcards: \(playthroughStats!.incorrectCards), timetaken: \(playthroughStats!.timeTaken), completed: \(playthroughStats!.completed)")
    }
    
    private func updatePlaythroughStats(completed: Bool = false) {
            guard let playthroughStats = playthroughStats else { return }

            playthroughStats.correctCards = correcttally
            playthroughStats.incorrectCards = totalCards - correcttally
            playthroughStats.timeTaken = Date.now.timeIntervalSince(starttime)
    
            try? modelContext.save()
        print("date played:\(playthroughStats.dateplayed) , deck: \(String(describing: playthroughStats.deck)), totalcards: \(playthroughStats.totalCards), correctcards: \(playthroughStats.correctCards), incorrectcards: \(playthroughStats.incorrectCards), timetaken: \(playthroughStats.timeTaken), completed: \(playthroughStats.completed)")
        
        }
    
    
    private func completeDeck() {
        guard let playthroughStats = playthroughStats else { return }
        
        playthroughStats.timeTaken = Date.now.timeIntervalSince(starttime)
        playthroughStats.correctCards = correcttally
        playthroughStats.incorrectCards = totalCards - correcttally
        playthroughStats.completed = true

        try? modelContext.save()
        
        print("date played:\(playthroughStats.dateplayed) , deck: \(String(describing: playthroughStats.deck)), totalcards: \(playthroughStats.totalCards), correctcards: \(playthroughStats.correctCards), incorrectcards: \(playthroughStats.incorrectCards), timetaken: \(playthroughStats.timeTaken), completed: \(playthroughStats.completed)")    }
}
