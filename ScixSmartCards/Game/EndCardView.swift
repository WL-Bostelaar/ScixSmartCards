//
//  EndCardView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI

struct EndCardView: View {
    var playthroughStats: PlaythroughStats
    
    var body: some View {
        VStack {
            Text("You've Reached the End!")
                .font(.system(size: 35, weight: .bold))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Text("That was a very productive \(playthroughStats.timeTaken) seconds")
                .font(.system(size: 20))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding()
            
            Text("You got \(playthroughStats.correctCards) out of \(playthroughStats.totalCards) cards correct.")
                .font(.system(size: 20))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding()
            
            if playthroughStats.correctCards >= Int(Double(playthroughStats.totalCards) * 0.8) {
                Text("Looks like you're doing well at this deck, now give another deck a go.")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
                
            } else if playthroughStats.correctCards < Int(Double(playthroughStats.totalCards) * 0.5) {
                Text("Have a few crackers and come back.")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
        }
        .padding()
    }
}
