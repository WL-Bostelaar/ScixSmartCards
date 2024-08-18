//
//  CardModel.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation
import SwiftData

@Model
class Card {
    var id: UUID
    var questiontype: String
    var question: String
    var answer: String
    var wronganswers: [String]?
    var deck: Deck?
    @Attribute(.externalStorage) var imageData: Data?
    var creationDate: Date
    
    // Learning Tracking
    var learnfactor: Double
    var difficulty: Int
    @Relationship(deleteRule: .cascade, inverse: \CardStatistics.card) var statistics: [CardStatistics]
    
    init(id: UUID = UUID(),
         questiontype: String = "QnA",
         question: String = "",
         answer: String = "",
         wronganswers: [String]? = nil,
         deck: Deck? = nil,
         imageData: Data? = nil,
         creationDate: Date = .now,
         learnfactor: Double = 3,
         difficulty: Int = 3,
         statistics: [CardStatistics] = [])
    {
        self.id = id
        self.questiontype = questiontype
        self.question = question
        self.answer = answer
        self.wronganswers = wronganswers
        self.deck = deck
        self.imageData = imageData
        self.creationDate = creationDate
        self.learnfactor = learnfactor
        self.difficulty = difficulty
        self.statistics = statistics
    }
}
