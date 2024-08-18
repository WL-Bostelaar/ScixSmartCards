//
//  CardStatisticsModel.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation
import SwiftData

@Model
class CardStatistics {
    var id: UUID
    var card: Card?
    var learnfactor: Double
    var answeredDate: Date
    var wasCorrect: Bool
    var timeTaken: TimeInterval
    var difficulty: Int
    
    init(id: UUID = UUID(), card: Card?, learnfactor: Double, answeredDate: Date, wasCorrect: Bool, timeTaken: TimeInterval, difficulty: Int) {
        self.id = id
        self.card = card
        self.learnfactor = learnfactor
        self.answeredDate = answeredDate
        self.wasCorrect = wasCorrect
        self.timeTaken = timeTaken
        self.difficulty = difficulty
    }
}
