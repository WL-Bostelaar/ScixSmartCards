//
//  QnAView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct QnAView: View {
    var card: Card
    var index: Int
    @Environment(\.modelContext) private var context
    @State private var startTime = Date()
    @State private var isAnswered = false
    @State private var answerflipped: Bool = false
    @State private var circleheight: CGFloat = 0
    @State private var answercardvisable: Bool = true
    @Binding var correcttally: Int
    @Binding var incorrecttally: Int
    
    //Drag Items
    @State private var currentDragOffset: CGFloat = 0
    @State private var puddlesize: CGFloat = 80
    @State private var puddleopacity: Double = 1
    var onAnswer: () -> Void


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
                            .frame(maxWidth: geometry.size.width)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    Spacer()
                    Text(card.question)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Text"))
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .top )
                .background(Color("Overlay"))
                .cornerRadius(15)
                .padding(.bottom)
                .shadow(radius: 5)
                
                //Answer Card
                ZStack {
                    HStack {
                        //Incorrect Button
                        if currentDragOffset > 0 {
                            ZStack {
                                if answercardvisable == false {
                                    Circle()
                                        .fill(.clear)
                                        .frame(width: 140, height: 140)
                                    
                                    Circle()
                                        .stroke(Color("GameRed").opacity(puddleopacity), lineWidth: 4)
                                        .frame(width: puddlesize, height: puddlesize)
                                }
                                
                                Circle()
                                    .fill(Color("Background"))
                                    .stroke(Color("GameRed"),lineWidth: 3)
                                    .frame(width: circleheight, height: circleheight)
                                
                                Image(systemName: "hand.thumbsdown")
                                    .resizable()
                                    .padding()
                                    .foregroundColor(Color("GameRed"))
                                    .frame(width: circleheight, height: circleheight)
                            }
                        }
                        if answercardvisable {
                            Spacer()
                        }
                        //Correct Button
                        if currentDragOffset < 0 {
                            ZStack {
                                if answercardvisable == false {
                                    Circle()
                                        .fill(.clear)
                                        .frame(width: 140, height: 140)
                                    
                                    Circle()
                                        .stroke(Color("GameGreen").opacity(puddleopacity), lineWidth: 4)
                                        .frame(width: puddlesize, height: puddlesize)
                                }
                                
                                Circle()
                                    .fill(Color("Background"))
                                    .stroke(Color("GameGreen"),lineWidth: 3)
                                    .frame(width: circleheight, height: circleheight)
                                
                                Image(systemName: "hand.thumbsup")
                                    .resizable()
                                    .padding()
                                    .foregroundColor(Color("GameGreen"))
                                    .frame(width: circleheight, height: circleheight)
                            }
                        }
                    }
                    .frame(minHeight: 250)
                    
                    if answercardvisable {
                        VStack {
                            if !answerflipped {
                                Text("Answer")
                                    .font(.system(size: 25, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(Color("Text"))
                                    .multilineTextAlignment(.leading)
                                    .padding()
                            } else {
                                VStack {
                                    Spacer()
                                    Text(card.answer)
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(Color("Text"))
                                        .multilineTextAlignment(.center)
                                        .padding()
                                    Spacer()
                                    
                                }
                                .transition(.slide)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 250, alignment: .center)
                        .background(Color("Overlay"))
                        .cornerRadius(15)
                        .onTapGesture{ withAnimation(.bouncy) {
                            answerflipped = true
                        }}
                        .transition(.move(edge: currentDragOffset < 0 ? .leading : .trailing))
                        .offset(x: currentDragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged {value in
                                    withAnimation(.spring()) {
                                        currentDragOffset = value.translation.width
                                        circleheights(size: value.translation.width)
                                    }
                                }
                                .onEnded {value in
                                    withAnimation(.spring()) {
                                        //Swipe Correct
                                        if currentDragOffset < -40 {
                                            answercardvisable = false
                                            circleheights(size: 80)
                                            answerCard(wasCorrect: true)
                                            puddle()
                                            
                                            //Swipe Incorrect
                                        } else if currentDragOffset > 40 {
                                            answercardvisable = false
                                            circleheights(size: 80)
                                            answerCard(wasCorrect: false)
                                            puddle()
                                        } else {
                                            currentDragOffset = 0
                                        }
                                    }
                                }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
                // End of main HStack
                .onAppear {
                    startTime = Date()
                    print("Loaded Card (appear): \(card.id) at index \(index)")

                }
                .onChange(of: card) {
                    startTime = Date()
                    print("Loaded Card (change): \(card.id) at index \(index)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
                .background(Color("Background"))
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func answerCard(wasCorrect: Bool) {
        //Find timeinterval
        let endTime = Date()
        let timeTaken = endTime.timeIntervalSince(startTime)
        
        //Create new stat
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
        
        //calculate learnfactor using the above stat
        card.learnfactor = calculateLearnFactor(stat: newStatistic)
        
        //updates the gameview correct tally
        if wasCorrect {
            correcttally += 1
        } else if !wasCorrect {
            incorrecttally += 1
        }
        
        newStatistic.learnfactor = card.learnfactor
        
        print("Card Learnfactor = \(card.learnfactor)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onAnswer()
            print("run onAnswer")
        }
    }

    private func circleheights(size: CGFloat) {
        let positiveSize = abs(size)
        let newSize = min(max(positiveSize, 0), 80)
        circleheight = newSize
    }
    
    private func puddle() {
        withAnimation(Animation.linear(duration: 1).repeatCount(2, autoreverses: false)) {
            puddlesize = 140
            puddleopacity = 0
        }
    }
}
