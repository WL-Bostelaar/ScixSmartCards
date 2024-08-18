//
//  CalculateDeckStatistics.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import Foundation

func CalculateDeckStatistics(for deck: Deck) -> DeckStatistics {
    let cards = deck.cards
    let now = Date()
    
    let averageLearnFactor = cards.map { $0.learnfactor }.average()
    let averageTimeTaken = cards.flatMap { $0.statistics.map { $0.timeTaken } }.average()
    let totalCorrectAnswers = cards.compactMap { $0.statistics.filter { $0.wasCorrect }.count }.reduce(0, +)
    let totalAnswers = cards.compactMap { $0.statistics.count }.reduce(0, +)
    let averageCorrectAnswers = totalAnswers > 0 ? Double(totalCorrectAnswers) / Double(totalAnswers) : 0
    let daysStudied = Set(cards.flatMap { $0.statistics.map { Calendar.current.startOfDay(for: $0.answeredDate) } }).count

    return DeckStatistics(
        deck: deck,
        averageLearnFactor: averageLearnFactor,
        averageTimeTaken: averageTimeTaken,
        daysStudied: daysStudied,
        averageCorrectAnswers: averageCorrectAnswers,
        calculationDate: now
    )
}

extension Collection where Element: Numeric {
    func sum() -> Element {
        return reduce(0, +)
    }
    
    func average() -> Double {
        guard !isEmpty else { return 0.0 }
        let total = self.sum()
        return Double("\(total)")! / Double(count)
    }
}
