//
//  DeckLoading.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation
import SwiftUI

//to store if cards are currently being generated from api

class DeckLoadingState: ObservableObject {
    @Published var loadingDecks: [UUID: Bool] = [:]

    func setLoading(for deckID: UUID, isLoading: Bool) {
        loadingDecks[deckID] = isLoading
    }

    func isLoading(for deckID: UUID) -> Bool {
        return loadingDecks[deckID] ?? false
    }
}
