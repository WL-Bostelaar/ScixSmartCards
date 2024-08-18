//
//  ReciteView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct ReciteView: View {
    var card: Card
    var index: Int
    @Environment(\.modelContext) private var context
    @State private var startTime = Date()
    @State private var isAnswered = false
    var onAnswer: () -> Void
    @Binding var correcttally: Int
    @Binding var incorrecttally: Int
    @State private var userInputs: [String]
    @State private var mode: Int = 1 // 1 for fill-in-the-blanks, 2 for recite mode
    @State private var maxAttempts: Int = 3
    @State private var attempts: Int = 0
    @State private var wordsToReplace: Set<Int> = []
    @State private var colors: [Color] = []
    @State private var showanswer: Bool = false // flips prompt card
    @State private var disabledone: Bool = false
    @State private var recitemodecolor: Color = Color("Text").opacity(0.6)

    init(card: Card, index: Int, correcttally: Binding<Int>, incorrecttally: Binding<Int>, onAnswer: @escaping () -> Void) {
        self.card = card
        self.index = index
        self._correcttally = correcttally
        self._incorrecttally = incorrecttally
        self.onAnswer = onAnswer
        self._userInputs = State(initialValue: Array(repeating: "", count: card.answer.split(separator: " ").count))
        self._mode = State(initialValue: card.difficulty == 5 ? 2 : 1)
        self._wordsToReplace = State(initialValue: Set())
        self._colors = State(initialValue: Array(repeating: Color.gray, count: card.answer.split(separator: " ").count))
    }

    var body: some View {
        VStack {
            // MARK: Question Card
            VStack {
                if !showanswer {
                    Spacer()
                    Text(card.question)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Text"))
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding()
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Tries: \(attempts)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color("Text"))
                        
                    }
                    .padding()
                } else {
                    Spacer()
                    Text(card.answer)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Text"))
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding()
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Tries: \(attempts)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color("Text"))
                        
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .top )
            .background(Color("Overlay"))
            .cornerRadius(15)
            .padding(.bottom)
            .onTapGesture{
                withAnimation(.default) {
                    showanswer.toggle()
                }
            }
            .transition(.blurReplace())
            
            // MARK: Answer Card
            VStack {
                if mode == 1 {
                    ScrollView {
                        FlowLayout {
                            ForEach(card.answer.split(separator: " ").indices, id: \.self) { i in
                                if wordsToReplace.contains(i) {
                                    if attempts < 3 {
                                        TextField("", text: $userInputs[i])
                                            .font(.system(size: 18, weight: .regular))
                                            .padding(3)
                                            .textInputAutocapitalization(.never)
                                            .frame(width: calculateTextWidth(for: card.answer.split(separator: " ")[i]) + 20)
                                            .multilineTextAlignment(.center)
                                            .overlay(RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.clear)
                                                .stroke(attempts == 0 ? Color("Text") : colors[i], lineWidth: 2))
                                    } else {
                                        Text(card.answer.split(separator: " ")[i])
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundStyle(Color(colors[i]))

                                    }
                                } else {
                                    Text(card.answer.split(separator: " ")[i])
                                        .foregroundColor(Color("Text"))
                                }
                            }
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 2)
                    }
                } else {
                    TextEditor(text: $userInputs[0])
                        .font(.system(size: 18, weight: .regular))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .padding()
                        .textInputAutocapitalization(.sentences)
                        .overlay(RoundedRectangle(cornerRadius: 15)
                            .fill(Color.clear)
                            .stroke(recitemodecolor, lineWidth: 2)
                    )
                        .frame(maxWidth: .infinity, minHeight: 160)

                }
                Button("Done") {
                    disabledone = true
                    checkAnswer()
                }
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                .clipShape(Capsule())
                .overlay(Capsule()
                    .fill(Color.clear)
                    .stroke(Color.accentColor.opacity(0.8),lineWidth: 2)
                )
                .foregroundColor(.accentColor)
                .disabled(disabledone)

                
            }
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .top )
            .padding()
            .background(Color("Overlay"))
            .cornerRadius(15)
            .padding(.bottom)
            .layoutPriority(1)

        }
        .onAppear {
            startTime = Date()
            print("Loaded Card (appear): \(card.id) at index \(index)")
            initializeUserInputs()
            determineWordsToReplace()
        }
        .onChange(of: card) {
            startTime = Date()
            print("Loaded Card (change): \(card.id) at index \(index)")
            initializeUserInputs()
            determineWordsToReplace()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .background(Color("Background"))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func initializeUserInputs() {
        let wordCount = card.answer.split(separator: " ").count
        userInputs = Array(repeating: "", count: wordCount)
        colors = Array(repeating: Color.gray, count: wordCount)
        mode = card.difficulty == 5 ? 2 : 1
    }

    private func determineWordsToReplace() {
        guard mode == 1 else { return }
        let percentages = [0.3, 0.45, 0.6, 0.8]
        let threshold = percentages[min(max(card.difficulty - 1, 0), 3)]
        let wordCount = card.answer.split(separator: " ").count
        let replaceCount = Int(Double(wordCount) * threshold)
        wordsToReplace = Set((0..<wordCount).shuffled().prefix(replaceCount))
    }

    private func checkAnswer() {
        let words = card.answer.split(separator: " ").map(String.init)
        
        if mode == 1 {
            var correctInputs = 0
            for i in words.indices {
                if wordsToReplace.contains(i) {
                    if userInputs[i] == words[i] {
                        colors[i] = Color("GameGreen")
                        correctInputs += 1
                    } else if userInputs[i].isEmpty {
                        colors[i] = Color("Text").opacity(0.6)
                    } else {
                        colors[i] = Color("GameRed")
                    }
                }
            }
            let correctPercentage = Double(correctInputs) / Double(wordsToReplace.count)
            if correctPercentage >= 0.8 {
                answerCard(wasCorrect: true)
            } else {
                attempts += 1
                if attempts >= maxAttempts {
                    answerCard(wasCorrect: false)
                } else {
                    disabledone = false
                }
            }
        } else {
            let userAnswer = userInputs.joined(separator: " ")
            let correctPercentage = similarityPercentage(between: userAnswer, and: card.answer)
            if correctPercentage >= 0.8 {
                answerCard(wasCorrect: true)
            } else {
                attempts += 1
                if attempts >= maxAttempts {
                    answerCard(wasCorrect: false)
                } else {
                    disabledone = false
                }
            }
        }
    }

    private func similarityPercentage(between input: String, and answer: String) -> Double {
        let inputWords = input.split(separator: " ")
        let answerWords = answer.split(separator: " ")
        let matchCount = zip(inputWords, answerWords).filter { $0 == $1 }.count
        return Double(matchCount) / Double(answerWords.count)
    }

    private func answerCard(wasCorrect: Bool) {
        // Find time interval
        let endTime = Date()
        let timeTaken = endTime.timeIntervalSince(startTime)
        
        // Create new stat
        let newStatistic = CardStatistics(
            id: UUID(),
            card: card,
            learnfactor: Double(card.learnfactor),
            answeredDate: endTime,
            wasCorrect: wasCorrect,
            timeTaken: timeTaken,
            difficulty: card.difficulty
        )
        context.insert(newStatistic)
        
        // Calculate learn factor using the above stat
        card.learnfactor = calculateLearnFactor(stat: newStatistic)
        
        // Update the game view correct tally
        if wasCorrect {
            correcttally += 1
        } else {
            incorrecttally += 1
        }
        
        newStatistic.learnfactor = card.learnfactor
        
        print("Card Learnfactor = \(card.learnfactor)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onAnswer()
            print("run onAnswer")
        }
        
    }
    private func calculateTextWidth(for word: Substring) -> CGFloat {
            let font = UIFont.systemFont(ofSize: 20)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let size = (String(word) as NSString).size(withAttributes: attributes)
        return size.width * 1.3
        }
}

