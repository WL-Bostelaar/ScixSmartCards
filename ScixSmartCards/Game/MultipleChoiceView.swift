import SwiftUI
import SwiftData
import Foundation

struct MultipleChoiceView: View {
    var card: Card
    var index: Int
    @Environment(\.modelContext) private var context
    @State private var startTime = Date()
    @State private var isAnswered = false
    @State private var selectedAnswer: String? = nil
    @State private var correctAnswerSelected = false
    @State private var shuffledAnswers: [String] = []
    var onAnswer: () -> Void
    @Binding var correcttally: Int
    @Binding var incorrecttally: Int


    var body: some View {
        GeometryReader { geometry in
            VStack {
                //Question Card
                VStack {
                    if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .frame(maxWidth: geometry.size.width, maxHeight: 400)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    Spacer()
                    Text(card.question)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Text"))
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()

                    
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color("Overlay"))
                .cornerRadius(15)
                .padding(.bottom)
                //Answer Card
                    VStack {
                        ForEach(shuffledAnswers, id: \.self) { answer in
                            Button(action: { answerCard(wasCorrect: answer == card.answer, selectedAnswer: answer) }) {
                                Text(answer)
                                    .font(.system(size: 20))
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(3)
                                    .foregroundStyle(Color.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color("Overlay"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(strokeColor(for: answer), lineWidth: 2)
                                    )
                                    .fixedSize(horizontal: false, vertical: true)

                            }
                            .disabled(isAnswered)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                    .background(Color("Overlay"))
                    .cornerRadius(15)
                    .fixedSize(horizontal: false, vertical: true)

            }
            .onAppear {
                startTime = Date()
                shuffledAnswers = shuffleAnswersOnce()
                print("Loaded Card (appear): \(card.id) at index \(index)")

            }
            .onChange(of: card) {
                startTime = Date()
                shuffledAnswers = shuffleAnswersOnce()
                print("Loaded Card (change): \(card.id) at index \(index)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .background(Color("Background"))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func answerCard(wasCorrect: Bool, selectedAnswer: String) {
        // Find time interval
        let endTime = Date()
        let timeTaken = endTime.timeIntervalSince(startTime)
        
        isAnswered = true
        
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
        
        // Calculate learnfactor using the above stat
        card.learnfactor = calculateLearnFactor(stat: newStatistic)
        
        newStatistic.learnfactor = card.learnfactor
        
        print("Card Learnfactor = \(card.learnfactor)")
        
        withAnimation {
            self.selectedAnswer = selectedAnswer
            self.correctAnswerSelected = wasCorrect
        }
        
        if wasCorrect {
            correcttally += 1
        } else if !wasCorrect {
            incorrecttally += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onAnswer()
        }
    }
    
    private func strokeColor(for answer: String) -> Color {
        guard let selectedAnswer = selectedAnswer else { return Color("Overlay2") }
        
        if selectedAnswer == answer {
            return correctAnswerSelected ? Color.green : Color.red
        } else if answer == card.answer {
            return Color.green
        } else {
            return Color("Overlay2")
        }
    }
    
    private func shouldShake(for answer: String) -> Bool {
        return selectedAnswer == answer && !correctAnswerSelected
    }
    
    private func shuffleAnswersOnce() -> [String] {
        var answers = card.wronganswers ?? []
        answers.append(card.answer)
        return answers.shuffled()
    }

}
