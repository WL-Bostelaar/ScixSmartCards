//
//  CardCollapsedView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI

struct CardCollapsedView: View {
    @State var card: Card
    @State private var difficultyColor: Color = .gray
    
    var body: some View {
        HStack {
            Text(card.question)
                .font(.system(size: 18))
                .padding(.bottom, 5)
                .foregroundStyle(Color("Text"))
            Spacer()
            
            if card.imageData != nil {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("Text").opacity(0.5))
            }
            if card.questiontype == "QnA" {
                Image(systemName: "doc.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(difficultyColor)
            }
            
            if card.questiontype == "Multiple Choice" {
                Image(systemName: "chart.bar.doc.horizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(difficultyColor)
            }
            if card.questiontype == "Recite" {
                Image(systemName: "doc.append")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(difficultyColor)
            }
        }.onAppear(perform: DifficultyColor)
        .padding()
    }
    private func DifficultyColor() {
        if card.difficulty == 3 {
            difficultyColor = Color("GameOrange").opacity(0.8)
        } else if card.difficulty < 3 {
            difficultyColor = Color("GameGreen").opacity(0.8)
        } else if card.difficulty > 3 {
            difficultyColor = Color("GameRed").opacity(0.8)
        }
    }
}

