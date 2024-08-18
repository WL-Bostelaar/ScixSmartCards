//
//  EditDeckView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct EditDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @State var deck: Deck
    @Binding var isPresented: Bool
    @State var tempCategory: String
    
    init(deck: Deck, isPresented: Binding<Bool>) {
        self._deck = State(initialValue: deck)
        self._isPresented = isPresented
        self._tempCategory = State(initialValue: deck.category)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Deck Name")) {
                    TextField("Deck Name", text: $deck.name, axis: .vertical)
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                }
                Section(header: Text("Category")) {
                    TextField("", text: $tempCategory, axis:.vertical)
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                }
            }
                Spacer()

                Button("Done", action: {
                    withAnimation(.spring()){
                        if !tempCategory.isEmpty {
                            deck.category = tempCategory
                            isPresented = false
                        } else {
                            return
                        }
                    }})
                .frame(width: 200, height: 40)
                .background(Color.accentColor)
                .foregroundStyle(Color("Text"))
                }
        .frame(width: 200, height: 250)
        .background(Color("Overlay"))
        .cornerRadius(10)
        .transition(.scale(1, anchor: .top))
        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
    }
}

