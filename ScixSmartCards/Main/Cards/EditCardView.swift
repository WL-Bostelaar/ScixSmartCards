//
//  EditCardView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData
import Foundation
import PhotosUI

struct EditCardView: View {
    @Environment(\.modelContext) var context
    @State var card: Card
    @Binding var cardview: CardTileView.CardViews
    @State private var selectedItem: PhotosPickerItem?
    var difficultylevels = [1,2,3,4,5]
    @State var difficultycolor: Color = .gray
    @State private var wronganswers: [String] = ["","",""]
    
    var body: some View {
        VStack {
            VStack{
                //Picture
                ZStack(alignment: .topTrailing) {
                    if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .frame(maxHeight: 400)
                        
                        Button(action: {
                            removeimage()
                        }) {
                            Image(systemName: "minus")
                                .resizable()
                                .scaledToFit()
                                .padding(6)
                                .frame(width: 30, height: 30)
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    
                }
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "photo.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 80, height: 70)
                        .foregroundColor(Color("Text").opacity(0.6))
                        .clipShape(Circle())
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            card.imageData = data
                        }
                    }
                }
                
                //Question
                Text("QUESTION")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color("OverlayContrast"))
                    .multilineTextAlignment(.leading)
                    .padding(.top)
                
                TextField("Enter question", text: $card.question, axis: .vertical)
                    .font(.system(size: 20, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color("Text"))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Overlay2")))
                
                //Answer
                Text("ANSWER")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color("OverlayContrast"))
                    .multilineTextAlignment(.leading)
                    .padding(.top)
                
                TextField("Enter answer", text: $card.answer, axis: .vertical)
                    .font(.system(size: 20, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color("Text"))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Overlay2")))
                
                //Multiple Choice Question
                if card.questiontype == "Multiple Choice" {
                    Text("WRONG ANSWERS")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("OverlayContrast"))
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    
                    ForEach(0..<3, id: \.self) { index in
                        TextField("Wrong Answer", text: Binding(
                            get: { card.wronganswers?[index] ?? "" },
                            set: { newValue in
                                if let _ = card.wronganswers {
                                    if card.wronganswers!.indices.contains(index) {
                                        card.wronganswers![index] = newValue
                                    } else {
                                        card.wronganswers!.append(newValue)
                                    }
                                } else {
                                    card.wronganswers = Array(repeating: "", count: 3)
                                    card.wronganswers![index] = newValue
                                }
                            }
                        ))
                        .font(.system(size: 20, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color("Text"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Overlay2")))
                    }
                }
                Spacer()
                
                //Difficulty
                Text("Difficulty")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color("OverlayContrast"))
                    .multilineTextAlignment(.leading)
                    .padding(.top)
                
                HStack{
                    ForEach(difficultylevels, id: \.self) { difficulty in
                        Button(action: {
                            card.difficulty = difficulty
                            checkColor()
                        }) {
                            Text("\(difficulty)")
                        }
                        .frame(minWidth: 30, maxWidth: 50, minHeight: 30, maxHeight: 30)
                        .foregroundColor(card.difficulty == difficulty ? difficultycolor : Color("Text").opacity(0.5))
                        .overlay( RoundedRectangle(cornerRadius: 15)
                            .stroke(card.difficulty == difficulty ? difficultycolor : Color("Text").opacity(0.5), lineWidth: 2)
                        )
                        .tag(difficulty)
                        .foregroundStyle(Color("Text"))
                        
                    }
                    
                }
                .onAppear(perform: checkColor)
                .onChange(of: card.difficulty, checkColor)
                
                
                Picker("Select difficulty", selection: $card.difficulty) {
                    
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
            }
            Spacer()
            //Done button
            Button("Done", action:
                    {withAnimation(.spring())
                {cardview = .expanded}})
            .font(.system(size: 20, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
            .background(Color("Button").opacity(0.5))
            .clipShape(Capsule())
            .overlay(Capsule()
                .fill(Color.clear)
                .stroke(Color.accentColor.opacity(0.8),lineWidth: 2)
            )                .foregroundColor(.accentColor)
        }
        .frame(alignment: .topLeading)
        .padding()
    }
    private func removeimage() {
        card.imageData = nil
        selectedItem = nil
    }
    private func checkColor() {
        if card.difficulty < 3 {
            difficultycolor = Color("GameGreen").opacity(0.5)
        } else if card.difficulty == 3 {
            difficultycolor = Color("GameOrange").opacity(0.5)
        } else if card.difficulty > 3 {
            difficultycolor = Color("GameRed").opacity(0.5)
        } else {
            difficultycolor = Color.blue
        }
    }
}
