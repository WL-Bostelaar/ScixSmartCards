//
//  CalculateLearnFactor.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation

func calculateLearnFactor(stat: CardStatistics) -> Double {
    var learnfactor = Double(stat.learnfactor)

    // Adjust for correctness
    if !stat.wasCorrect {
        learnfactor += 2.0
    }

    // Adjust for time since last answered
    let daysSinceLastAnswered = Date().timeIntervalSince(stat.answeredDate) / (60 * 60 * 24)
    if daysSinceLastAnswered > 2 {
        learnfactor += 0.5
    }

    // Adjust for time taken (only for QnA and Multiple Choice)
    if stat.card!.questiontype != "Recite" {
        if stat.timeTaken < 2 {
            learnfactor -= 1.0
        }
    }

    // Ensure learnfactor is within the range [1, 10]
    learnfactor = min(max(learnfactor, 1), 10)

    return learnfactor
}
