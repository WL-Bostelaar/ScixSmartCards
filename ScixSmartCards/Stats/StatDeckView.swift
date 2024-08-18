//
//  StatDeckView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

// Circle chart showing learnfactor
// deck ranking based on learnfactor
// deck consits of # of each card type
// time played deck
// correect answer average per play
// times played
// times completed
// list of all cards
// date last played

import SwiftUI
import SwiftData
import Charts

struct StatDeckView: View {
    var deck: Deck
    //Deck learnfactor guage
    @State private var chartdata: [Double] = []
    @State private var chartColor: Color = Color("Overlay")
    @State private var adjustedLF: Double = 0
    @State private var other: Double = 0

    
    //Stats main
    @Query private var playthroughStats: [PlaythroughStats]
    @Query private var deckStats: [DeckStatistics]
    @Query private var cardstats: [CardStatistics]
    @State private var filteredPlaythroughStats: [PlaythroughStats] = []
    @State private var filteredDeckStats: [DeckStatistics] = []
    
    //Stats Each
    @State private var timePlayed: Int = 0
    @State private var timein: String = "minutes"
    @State private var correctAnswerAvg: Double = 0
    @State private var timesPlayed: Int = 0
    @State private var timesCompleted: Int = 0
    
    //Animation
    @State private var animation: Double = 0
    
    
    var body: some View {
        VStack {
            ScrollView {
                
                ZStack {
                    Gauge(value: adjustedLF, in: 0...10) {} currentValueLabel: {
                        
                    }
                    .gaugeStyle(CustomGauge {
                    })
                    
                    VStack {
                        Text("\(Int(adjustedLF.rounded()))")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundStyle(Color("Text"))
                        Text("LEARNFACTOR")
                            .font(.system(size: 11))
                    }
                    .frame(alignment: .center)
                }
                
                Text("Stats")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                StatRowView(title: "Time Played:", value: "\(timePlayed) \(timein)")
                StatRowView(title: "Correct Answer Average:", value: "\(correctAnswerAvg)")
                StatRowView(title: "Times Played:", value: "\(timesPlayed)")
                StatRowView(title: "Times Completed:", value: "\(timesCompleted)")
            }
            .padding()
            .onAppear{
                
                findChartData()
                getStats()
                withAnimation(.snappy(duration: 1.5, extraBounce: 0.2)) {
                    animation = 1
                }
            }
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func getStats() {
        filteredPlaythroughStats = playthroughStats.filter { $0.deck?.id == deck.id }
        filteredDeckStats = deckStats.filter { $0.deck?.id == deck.id }
        
        timePlayed = Int(filteredPlaythroughStats.reduce(0.0) { $0 + $1.timeTaken }.rounded())
        
        if timePlayed > 60 {
            timePlayed = timePlayed / 60
            if timePlayed > 1 {
                timein = "hours"
            } else {
                timein = "hour"
            }
        }
        
        correctAnswerAvg = Double(filteredPlaythroughStats.reduce(0) { $0 + $1.correctCards }) / Double(filteredPlaythroughStats.reduce(0) { $0 + $1.incorrectCards })
        
        timesPlayed = filteredPlaythroughStats.count
        
        timesCompleted = filteredPlaythroughStats.filter { $0.completed }.count
    }
    
    private func findChartData() {
        let averageLearnFactor = deck.cards.map { $0.learnfactor }.averageValue
        adjustedLF = 10 - averageLearnFactor // Flip the learn factor
        other = 15 - adjustedLF
        chartdata = [other, adjustedLF]
        
        if adjustedLF < 4 {
            chartColor = Color("GameRed")
        } else if adjustedLF > 6 {
            chartColor = Color("GameGreen")
        } else {
            chartColor = Color("GameOrange")
        }
    }
}

struct StatRowView: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundStyle(Color("Text"))
            Spacer()
            Text(value)
                .font(.system(size: 18))
                .foregroundStyle(Color("Text"))
        }
        .padding()
        .background(Color("Overlay"))
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
    }
}
