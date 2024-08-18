//
//  StatDeckTileView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import Charts

struct StatDeckTileView: View {
    var deck: Deck
    
    //Deck learnfactor guage
    @State private var chartdata: [Double] = []
    @State private var chartColor: Color = Color("Overlay")
    @State private var adjustedValue: Double = 0
    
    var body: some View {
        NavigationLink(destination: StatDeckView(deck: deck)) {
            VStack {
                HStack {
                    Text(deck.name)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .padding()
                        .foregroundStyle(Color("Text"))
                    Spacer()
                    Chart {
                        ForEach(chartdata, id : \.self) { value in
                            SectorMark(
                                angle: .value("data", value.rounded()),
                                innerRadius: .ratio(0.65),
                                angularInset: 2.0
                            )
                            .cornerRadius(20)
                            .foregroundStyle(value == Double(adjustedValue) ? Color(chartColor) : Color("Overlay"))
                        }
                    }
                    .rotationEffect(.degrees(90))
                    .frame(width: 30, height: 30, alignment: .trailing)
                    .padding()
                    
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color("Overlay"), Color("Overlay")]), startPoint: .top, endPoint: .bottom))
                .frame(maxWidth: .infinity, minHeight: 30)
                .cornerRadius(15)
                .onAppear{
                    findChartData()
                    print(deck.name)
                    print(deck.cards.count)

                }
            }
        }
    }
    private func findChartData() {
        let averageLearnFactor = deck.cards.map { $0.learnfactor }.averageValue
        adjustedValue = 10 - averageLearnFactor // Flip the learn factor
        let x = Double(5)
        let other = 10 - adjustedValue
        chartdata = [x, other, adjustedValue]

        if adjustedValue < 4 {
            chartColor = Color("GameRed")
        } else if adjustedValue > 6 {
            chartColor = Color("GameGreen")
        } else {
            chartColor = Color("GameOrange")
        }
        print(chartdata)
    }
}
