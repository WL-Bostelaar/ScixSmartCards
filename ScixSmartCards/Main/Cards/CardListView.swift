//
//  CardListView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct CardListView: View {
    @Bindable var deck: Deck
    @State private var buttonexpanded: Bool = false
    @State private var isShowingAddCard: Bool = false
    @State private var isshowingAICard: Bool = false
    @State var isShowingDeleteButton: Bool = false
    @EnvironmentObject var deckLoadingState: DeckLoadingState
    
    @State private var userpremiumalert: Bool = false
    
    @State private var exportURL: Data? // for exporting
    @State private var showingExporter: Bool = false
    
    @State private var exportingDeck: ExportableDeck?
    

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(deck.cards.sorted(by: {$0.creationDate < $1.creationDate})) { card in
                        CardTileView(card: card, deleteAction: {
                            deleteCard(card)
                        })
                    }
                }
                
                
                if deckLoadingState.isLoading(for: deck.id) {
                    Spacer()
                    ProgressView("Generating cards...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                Spacer()
                
                if !buttonexpanded {
                    Button(action: {
                        withAnimation(.spring) {
                            buttonexpanded = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(Color("Overlay"))
                            .foregroundColor(Color("Text").opacity(0.6))
                            .clipShape(Circle())
                            .padding(.vertical, 30)
                    }
                    .transition(.push(from: .leading))
                    
                } else if buttonexpanded {
                    HStack {
                        Button(action: {
                                isshowingAICard = true
                        }) {
                            Image(systemName: "waveform.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 60, height: 60)
                                .background(Color("Overlay"))
                                .foregroundColor(Color("Text"))
                                .clipShape(Circle())
                                .padding(10)
                        }

                        Spacer()
                        
                        Button(action: {
                            isShowingAddCard = true
                        }) {
                            Image(systemName: "note.text.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 60, height: 60)
                                .background(Color("Overlay"))
                                .foregroundColor(Color("Text"))
                                .clipShape(Circle())
                                .padding(10)
                        }
                    }
                    .background(Color("Overlay2"))
                    .clipShape(Capsule())
                    .frame(maxWidth: 180, maxHeight: 80,  alignment: .center)
                    .padding(.vertical, 30)
                    .transition(.scale(scale: 0.5, anchor: .center))
                }
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddCard) {
            AddCardView(deck: deck)
        }
        .sheet(isPresented: $isshowingAICard) {
            AddAICardView(deck: deck)
        }
        .toolbar {
            Button {
                exportingDeck = exportDeck(deck: deck)
                if exportingDeck != nil {
                    showingExporter = true
                } else {
                    print("exportingDeck empty")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .fileExporter(isPresented: $showingExporter, document: exportingDeck.map { DeckDocument(deck: $0) }, contentType: .scix, defaultFilename: deck.name) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                    showingExporter = false
                case .failure(let error):
                    print(error.localizedDescription)
                    showingExporter = false
                }
        }
        .alert("Get premium to use this feature", isPresented: $userpremiumalert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please read this.")
        }
    }
    
    private func deleteCard(_ card: Card) {
            if let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
                deck.cards.remove(at: index)
            }
        }
}

//MARK: Exporting
func showDocumentPicker(url: URL) {
    let documentPicker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(documentPicker, animated: true, completion: nil)
    }
}


