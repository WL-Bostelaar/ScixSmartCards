//
//  ScixSmartCardsApp.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

@main
struct ScixApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var deckLoadingState = DeckLoadingState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deckLoadingState) // State to pass through if get GPT cards is running for that deck
        }
        .modelContainer(for: [Deck.self, Card.self, DeckStatistics.self, CardStatistics.self, PlaythroughStats.self])
    }
}
