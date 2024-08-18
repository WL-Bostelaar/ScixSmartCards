//
//  DeckModel.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class Deck {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var deckColor: DeckColor
    var deckImage: deckImages
    @Relationship(deleteRule: .cascade) var statistics: [DeckStatistics]
    @Relationship(deleteRule: .cascade, inverse: \Card.deck) var cards: [Card]
    @Relationship(deleteRule: .cascade, inverse: \PlaythroughStats.deck) var playthroughs: [PlaythroughStats]

    init(id: UUID = UUID(),
         name: String = "",
         category: String = "",
         deckColor: DeckColor = DeckColor.nocolor,
         deckImage: deckImages = deckImages.DeckTile1,
         statistics: [DeckStatistics] = [],
         cards: [Card] = [],
         playthroughs: [PlaythroughStats] = []
    )
    {
        self.id = id
        self.name = name
        self.category = category
        self.deckColor = deckColor
        self.deckImage = deckImage
        self.statistics = statistics
        self.cards = cards
        self.playthroughs = playthroughs
    }
}

enum DeckColor: CaseIterable, Codable {
    case nocolor
    case red
    case green
    case blue
    case purple
    case yellow
    case orange
    
    var color: Color {
        switch self {
        case .nocolor:
            return Color("Overlay")
        case .red:
            return Color("DeckRed")
        case .green:
            return Color("DeckGreen")
        case .blue:
            return Color("DeckBlue")
        case .purple:
            return Color("DeckPurple")
        case .yellow:
            return Color("DeckYellow")
        case .orange:
            return Color("DeckOrange")
        }
    }
    
    var displayName: String {
        switch self {
        case .nocolor:
            return "No Color"
        case .red:
            return "Red"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        case .yellow:
            return "Yellow"
        case .orange:
            return "Orange"
        }
    }
}

enum deckImages: String, CaseIterable, Codable {
    case DeckTile1 = "DeckTile1"
    case DeckTile2 = "DeckTile2"
    case DeckTile3 = "DeckTile3"
    case DeckTile4 = "DeckTile4"
    case DeckTile5 = "DeckTile5"
    case DeckTile6 = "DeckTile6"
    
    var image: Image {
        return Image(self.rawValue)
    }
}
