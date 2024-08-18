//
//  AddDeckView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData
import Combine

struct AddDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query public var decks: [Deck]
    @State private var newDeckName = ""
    @State private var selectedColor: DeckColor = .nocolor
    @State private var newCategoryName = ""
    @State private var selectedCategory = ""
    @State private var showingAddCategory = false
    
    @EnvironmentObject var deckLoadingState: DeckLoadingState

    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 120, maximum: .infinity))
    ]
    
    var body: some View {
        VStack {
            Text("Add Deck")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                .padding(.horizontal)
            
            Form {
                Section(header: Text("Deck Name")) {
                    TextField("", text: $newDeckName)
                        .foregroundStyle(Color("Text"))
                }
                .listRowBackground(Color.overlay)
                
                Section(header: Text("Category")) {
                    if decks.isEmpty {
                        TextField("New Category", text: $newCategoryName)
                            .foregroundStyle(Color("Text"))
                    } else {
                        ForEach(decks.map { $0.category }.unique(), id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                showingAddCategory = false
                            }) {
                                Text(category)
                                    .foregroundColor(selectedCategory == category ? Color.accentColor.opacity(0.8) : Color("Text").opacity(0.5))
                            }
                            .tag(category)
                        }
                        
                        Button(action: {
                            showingAddCategory = true
                            selectedCategory = ""
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                Text("Add Category")
                            }
                            .foregroundColor(showingAddCategory ? Color.accentColor.opacity(1) : Color.accentColor.opacity(0.5))
                        }
                    }
                    if showingAddCategory {
                        TextField("New Category", text: $selectedCategory)
                            .foregroundStyle(Color("Text"))
                    }
                }
                .listRowBackground(Color.overlay)
                
                Section(header: Text("Color"), footer: Text("Colors let you combine decks to study")) {
                    //Fake Picker - New
                    HStack {
                        ForEach(DeckColor.allCases, id: \.self) { color in
                            Button(action: {
                                withAnimation(.spring){
                                    selectedColor = color
                                }
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedColor == color ? Color("Overlay2").opacity(0.7) : Color.clear)
                                    
                                    Image(systemName: "circle.hexagongrid.circle")
                                        .scaledToFit()
                                        .foregroundColor(color.color)
                                }
                            })
                            .padding(2)
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .listRowBackground(Color.overlay)

            }
            .scrollContentBackground(.hidden)
            
            Spacer()
            
            Button(action: addDeck) {
                Text("Add Deck")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .foregroundStyle(Color("Text"))
            }
            .frame(maxWidth: .infinity, minHeight: 25)
            .padding(1)
            .background(Color("LightAccent"))
            
        }
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color("LightAccent"),lineWidth: 2)
        )
    }
    
    private func addDeck() {
        let category = decks.isEmpty ? newCategoryName : selectedCategory
        let deckimage = deckImages.allCases.randomElement()!
        if !category.isEmpty {
            let newDeck = Deck(name: newDeckName, category: category, deckColor: selectedColor, deckImage: deckimage)
            modelContext.insert(newDeck)
            newDeckName = ""
            selectedCategory = ""
            newCategoryName = ""
            showingAddCategory = false
            dismiss()
        }
    }
}

