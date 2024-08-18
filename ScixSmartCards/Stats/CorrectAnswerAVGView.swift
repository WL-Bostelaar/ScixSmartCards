//
//  CorrectAnswerAVGView.swift
//  Scix
//
//  Created by William Bostelaar on 22/6/2024.
//

import SwiftUI
import SwiftData
import Charts

struct CorrectAnswerAVGView: View {
    @Query var playthroughStats: [PlaythroughStats]
    @State private var timeByDate: [Date: Double] = [:]
    @State private var isLoading = true
    @State private var animationValue: Double = 0
    @State private var largesttime: Int = 30
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(height: 200)
            } else {
                Chart {
                    ForEach(timeByDate.keys.sorted(), id: \.self) { date in
                        if let totalTime = timeByDate[date] {
                            BarMark(
                                x: .value("Date", date, unit: .day),
                                y: .value("Total Play Time (minutes)", totalTime * animationValue)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...largesttime)
                .onAppear {
                    withAnimation(.bouncy(duration: 1.5, extraBounce: 0.2)) {
                        animationValue = 1
                    }
                }
                .chartXAxis(.hidden)
            }
        }
        .onAppear(perform: preprocessStatistics)
        .frame(maxWidth: .infinity)
    }
    
    private func preprocessStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            
            var tempTimeByDate: [Date: Double] = [:]
            
            for stat in playthroughStats {
                let dayStart = calendar.startOfDay(for: stat.dateplayed)
                let timeInMinutes = stat.timeTaken / 60.0
                if tempTimeByDate[dayStart] != nil {
                    tempTimeByDate[dayStart]? += timeInMinutes
                } else {
                    tempTimeByDate[dayStart] = timeInMinutes
                }
            }
            
            // Ensure the last 7 days are always included
            let today = calendar.startOfDay(for: Date())
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                if tempTimeByDate[date] == nil {
                    tempTimeByDate[date] = 0
                }
            }
            
            let maxTime = tempTimeByDate.values.max() ?? 30
            
            DispatchQueue.main.async {
                timeByDate = tempTimeByDate
                largesttime = max(5, Int(maxTime))
                isLoading = false
                
                // Print the processed data
                for (date, time) in timeByDate {
                    print("Date: \(date), Total Play Time: \(time) minutes")
                }
            }
        }
    }
}

