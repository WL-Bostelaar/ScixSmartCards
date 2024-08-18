//
//  OverviewChart.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData
import Charts

struct OverviewChart: View {
    var decks: [Deck]
    @State private var statisticsByDate: [Date: Double] = [:]
    @State private var isLoading = true
    @State private var animationValue: Double = 0
    @State private var isflipped: Bool = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(height: 200)
            } else {
                //if the deck is empty show prompt
                if decks.isEmpty {
                    Text("Create decks to view stats.")
                        .font(.system(size: 18).bold())
                        .frame(height: 200)
                        .foregroundStyle(Color("Text"))
                } else {
                    //flipping shows the info about the chart
                    if !isflipped {
                        Chart {
                            ForEach(statisticsByDate.keys.sorted(), id: \.self) { date in
                                if let averageLearnFactor = statisticsByDate[date] {
                                    BarMark(
                                        x: .value("Date", date, unit: .day),
                                        y: .value("Average Learn Factor", averageLearnFactor * animationValue)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.red]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 0...10)
                        .chartXAxis(.hidden)
                        .onAppear {
                            withAnimation(.snappy(duration: 1.5, extraBounce: 0.2)) {
                                animationValue = 1
                            }
                        }
                    } else if isflipped {
                        Text("Shows your current progress for all decks, per day")
                            .font(.system(size: 18))
                            .frame(height: 200)
                            .foregroundStyle(Color("Text"))
                    }
                }
            }
        }
        .onAppear(perform: preprocessStatistics)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation() {
                isflipped.toggle()
            }
        }
        .transition(.blurReplace)
    }

    private func preprocessStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let allStatistics = decks.flatMap { $0.statistics }

            // Debugging prints for all statistics
            print("All statistics: \(allStatistics)")
            
            var tempStatisticsByDate: [Date: [Double]] = [:]
            
            for stat in allStatistics {
                let dayStart = calendar.startOfDay(for: stat.calculationDate)
                if tempStatisticsByDate[dayStart] != nil {
                    tempStatisticsByDate[dayStart]?.append(stat.averageLearnFactor)
                } else {
                    tempStatisticsByDate[dayStart] = [stat.averageLearnFactor]
                }
            }
            
            var averagedStatistics: [Date: Double] = [:]
            for (date, learnFactors) in tempStatisticsByDate {
                let dailyAverage = abs(learnFactors.averageValue - 10) // Makes the value opposite (lower is better)
                averagedStatistics[date] = dailyAverage
            }
            
            // Ensure the last 7 days are always included
            let today = calendar.startOfDay(for: Date())
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                if averagedStatistics[date] == nil {
                    averagedStatistics[date] = 0
                }
            }

            DispatchQueue.main.async {
                statisticsByDate = averagedStatistics
                isLoading = false
                
                // Print the processed data
                for (date, average) in statisticsByDate {
                    print("Date: \(date), Average Learn Factor: \(average)")
                }
            }
        }
    }
}

extension Collection where Element == Double {
    var averageValue: Double {
        return isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}
