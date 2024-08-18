//
//  DeckStatisticsModel.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation
import SwiftData

@Model
class DeckStatistics {
    var id: UUID
    var deck: Deck?
    var averageLearnFactor: Double
    var averageTimeTaken: Double
    var daysStudied: Int
    var averageCorrectAnswers: Double
    var calculationDate: Date

    init(id: UUID = UUID(), deck: Deck?, averageLearnFactor: Double, averageTimeTaken: Double, daysStudied: Int, averageCorrectAnswers: Double, calculationDate: Date = Date()) {
        self.id = id
        self.deck = deck
        self.averageLearnFactor = averageLearnFactor
        self.averageTimeTaken = averageTimeTaken
        self.daysStudied = daysStudied
        self.averageCorrectAnswers = averageCorrectAnswers
        self.calculationDate = calculationDate
    }
}
