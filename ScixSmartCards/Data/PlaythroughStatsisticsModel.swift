//
//  PlaythroughStatsisticsModel.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation
import SwiftData

@Model
class PlaythroughStats {
    var id: UUID
    var dateplayed: Date
    var deck: Deck?
    var correctCards: Int
    var incorrectCards: Int
    var totalCards: Int
    var timeTaken: TimeInterval
    var completed: Bool
    
    init(id: UUID = UUID(),
         dateplayed: Date = Date(),
         deck: Deck?,
         correctCards: Int = 0,
         incorrectCards: Int = 0,
         totalCards: Int = 0,
         timeTaken: TimeInterval = 0,
         completed: Bool = false
    )
    {
        self.id = id
        self.dateplayed = dateplayed
        self.deck = deck
        self.correctCards = correctCards
        self.incorrectCards = incorrectCards
        self.totalCards = totalCards
        self.timeTaken = timeTaken
        self.completed = completed
    }
    
}
