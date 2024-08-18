//
//  ShareDeck.swift
//  Scix
//
//  Created by William Bostelaar on 1/7/2024.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

//MARK: Export deck structures
struct ExportableDeck: Codable {
    var name: String
    var category: String
    var cards: [ExportableCard]
}

struct ExportableCard: Codable {
    var questiontype: String
    var question: String
    var answer: String
    var imageData: Data?
    var wronganswers: [String]?
    var difficulty: Double
}

func exportDeck(deck: Deck) -> ExportableDeck? {
    
    let exportableCards = deck.cards.map { card in
        ExportableCard(
            questiontype: card.questiontype,
            question: card.question,
            answer: card.answer,
            imageData: card.imageData,
            wronganswers: card.wronganswers,
            difficulty: card.learnfactor
        )
    }
    
    let exportableDeck = ExportableDeck(
        name: deck.name,
        category: deck.category,
        cards: exportableCards
    )
    
    return exportableDeck
}

struct DeckDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.scix] }
    
    var deck: ExportableDeck
    
    init(deck: ExportableDeck) {
        self.deck = deck
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let decodedDeck = try? JSONDecoder().decode(ExportableDeck.self, from: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.deck = decodedDeck
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(deck)
        return FileWrapper(regularFileWithContents: data)
    }
}
