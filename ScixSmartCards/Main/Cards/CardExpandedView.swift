//
//  CardExpandedView.swift
//  FlashCards
//
//  Created by William Bostelaar on 8/6/2024.
//

import SwiftUI

struct CardExpandedView: View {
    @State var card: Card
    
    var body: some View {
        VStack {
            if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .frame(maxHeight: 400)
            }
            Text("QUESTION")
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("OverlayContrast"))
                .multilineTextAlignment(.leading)


            Text(card.question)
                .font(.system(size: 20, weight: .regular))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color("Text"))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Overlay2")))
            
            Text("ANSWER")
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("OverlayContrast"))
                .multilineTextAlignment(.leading)
                .padding(.top)
            
            Text(card.answer)
                .font(.system(size: 20, weight: .regular))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color("Text"))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Overlay2")))

            if card.questiontype == "Multiple Choice" {
                    Text("WRONG ANSWERS")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("OverlayContrast"))
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    
                if let wronganswers = card.wronganswers, !wronganswers.isEmpty {
                    ForEach(wronganswers, id: \.self) { wrongAnswer in
                        Text(wrongAnswer)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color("Text"))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color("Overlay2")))
                    }
                }
            }
        }
        .padding()
    }
}
