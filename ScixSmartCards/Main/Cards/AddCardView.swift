//
//  AddCardView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var deck: Deck
    
    @State private var questiontype = "QnA"
    @State private var question = ""
    @State private var answer = ""
    @State private var wronganswers: [String] = ["", "", ""]
    @State private var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    @State private var difficulty = 3
    @State private var isImagePickerPresented: Bool = false
    let difficultyLevels = [1, 2, 3, 4, 5]
    @State private var difficultyColor: Color = .gray
    var questiontypename: Bool {questiontype == "QnA" || questiontype == "Multiple Choice"}
    
    var body: some View {
        VStack{
            
            Text("Add Card")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                .padding(.horizontal)
            
            Form {
                Section(header: Text("Card Type")){
                    Picker("Question Type", selection: $questiontype) {
                        Text("QnA").tag("QnA")
                        Text("Multiple Choice").tag("Multiple Choice")
                        Text("Recite").tag("Recite")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Picture")){
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        ZStack(alignment: .topTrailing){
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .frame(maxHeight: 400)
                                .padding()
                            
                            Button(action: {
                                removeimage()
                            }) {
                                Image(systemName: "minus")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                                    .background(Color.red)
                                    .foregroundColor(Color.white)
                                    .clipShape(Circle())
                                    .frame(width: 30, height: 30)
                            }
                            .frame(width: 30, height: 30)
                        }
                    }
                    if ((imageData?.isEmpty) == nil) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                Text("Add Picture")
                            }
                            .foregroundColor(Color.white.opacity(0.2))
                            .onChange(of: selectedItem) {
                                Task {
                                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                        imageData = data
                                    }
                                    isImagePickerPresented.toggle()
                                }
                            }
                        }
                    }
                }
                
                Section(header: questiontypename ? Text("Question"): Text("Promt")) {
                    TextField("", text: $question, axis: .vertical)
                        .foregroundStyle(Color("Text"))
                }
                
                Section(header: Text("Answer")){
                    TextField("", text: $answer, axis: .vertical)
                        .foregroundStyle(Color("Text"))
                }
                if questiontype == "Multiple Choice" {
                    Section(header: Text("Wrong Answers")){
                        ForEach(0..<3, id: \.self) { index in
                            TextField("Optional", text: $wronganswers[index], axis: .vertical)
                        }
                    }
                }
                
                Section(header: Text("Difficulty")){
                    Picker("Select difficulty", selection: $difficulty) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text("\(level)")
                                .tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Button(action: {
                addCard()
                dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .foregroundStyle(Color("Text"))
            }
            .disabled(question.isEmpty || answer.isEmpty || (questiontype == "Multiple Choice" && wronganswers[0].isEmpty))
            .frame(maxWidth: .infinity, minHeight: 25)
            .padding(1)
            .background(Color("LightAccent"))
        }
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color("LightAccent"),lineWidth: 2)
        )
    }

    private func addCard() {
        let nonEmptyWrongAnswers = wronganswers.filter { !$0.isEmpty }
        let newCard = Card(
            questiontype: questiontype,
            question: question,
            answer: answer,
            wronganswers: questiontype == "Multiple Choice" ? nonEmptyWrongAnswers : nil,
            deck: deck,
            imageData: imageData,
            creationDate: Date(),
            learnfactor: Double(difficulty),
            difficulty: difficulty,
            statistics: []
            )
        
        modelContext.insert(newCard)
        deck.cards.append(newCard)
        print("New Card Created: Question Type: \(newCard.questiontype), Question: \(newCard.question), Answer: \(newCard.answer), Difficulty: \(newCard.difficulty), Wrong Answers: \(newCard.wronganswers ?? [] ), Learnfactor: \(newCard.learnfactor) ")
    }
    
    private func removeimage() {
        imageData = nil
        selectedItem = nil
    }
}
