
//
//  AddAICardView.swift
//  Scix
//
//  Created by William Bostelaar on 27/6/2024.
//

import SwiftUI
import PDFKit

struct AddAICardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var deckLoadingState: DeckLoadingState
    @Bindable var deck: Deck
    
    @State private var selectAddMethod: addMethod = .prompt // user chooses method (enum)
    
    @State private var generateCardsPrompt: String = ""
    @State private var numberCardsToGenerate: Double = 1
    @State private var isLoading = false // shows cards loading
    @State private var errorMessage: String?
    @State private var pdffile: PDFDocument? // stores users pdf doc
    @State private var pdfexists: Bool = false // makes sure there is a pdf before actioning the done button
    @State private var pdfFileViewer: Bool = false // Shows file picker for pdf
    @State private var ErrorSelection: Bool = false // alert for done button
    
    var body: some View {
        VStack {
            //MARK: Title
            Text("Generate Cards")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color("Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                .padding(.horizontal)
            
            
            //MARK: Choose Add method (enum)
            Picker("Question Type", selection: $selectAddMethod) {
                ForEach(addMethod.allCases, id: \.self) { method in
                    Text(method.rawValue.capitalized).tag(method)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            

//                Section(header: Text("Select a method to add cards")) {
//                    Picker("Question Type", selection: $addmethod) {
//                        Text("Prompt").tag("Prompt")
//                        Text("Notes").tag("Notes")
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                }
                //MARK: User Prompt
                if selectAddMethod == .prompt{
                    Form {
                        Section(header: Text("Enter a prompt")) {
                            TextField("Describe your deck", text: $generateCardsPrompt)
                                .foregroundStyle(Color("Text"))
                        }
                        Section(header: Text("Select number of cards")){
                            Slider(value: $numberCardsToGenerate, in: 1...20, step: 1) {
                                Text("numberCardsToGenerate")
                            } minimumValueLabel: {
                                Text("1")
                            } maximumValueLabel: {
                                Text("20")
                            }
                            Text("\(Int(numberCardsToGenerate))")
                        }
                    }
                //MARK: User Provides Notes
                } else if selectAddMethod == .text {
                        Form {
                            Section(header: Text("Add you own notes")) {
                                TextField("Paste your notes here", text: $generateCardsPrompt, axis: .vertical)
                                    .foregroundStyle(Color("Text"))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            Section(header: Text("Select number of cards")){
                                Slider(value: $numberCardsToGenerate, in: 1...20, step: 1) {
                                    Text("numberCardsToGenerate")
                                } minimumValueLabel: {
                                    Text("1")
                                } maximumValueLabel: {
                                    Text("20")
                                }
                                Text("\(Int(numberCardsToGenerate))")
                            }
                        }
                    //MARK: User povides Doc
                    } else {
                        Form {
                            Section(header: Text("Import a PDF")) {
                                Button("Import") {
                                    pdfFileViewer = true
                                }
                                .fileImporter(isPresented: $pdfFileViewer, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                                    switch result {
                                    case .success(let fileurl):
                                        if let url = fileurl.first {                                         let pdfDocument = PDFDocument(url: url)
                                            pdffile = pdfDocument
                                            pdfexists = true
                                        } else {
                                            print("Failed to load PDF document.")
                                            pdfexists = false
                                        }
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            if pdfexists == true {
                                Text("pdf imported")
                            }
                            
                            Section(header: Text("Select number of cards")){
                                Slider(value: $numberCardsToGenerate, in: 1...20, step: 1) {
                                    Text("numberCardsToGenerate")
                                } minimumValueLabel: {
                                    Text("1")
                                } maximumValueLabel: {
                                    Text("20")
                                }
                                Text("\(Int(numberCardsToGenerate))")
                            }
                        }
                }
                //MARK: Number of cards & button
            Button(action: {
                if selectAddMethod == .prompt || selectAddMethod == .text {
                    generateCards(messagetext: generateCardsPrompt, addmethod: selectAddMethod, numberOfCards: Int(numberCardsToGenerate), for: deck, context: modelContext, deckLoadingState: deckLoadingState)
                    dismiss()
                } else if selectAddMethod == .pdf {
                    if pdfexists == true {
                        pdfreader(PDFDoc: pdffile!, addmethod: selectAddMethod, numberOfCards: Int(numberCardsToGenerate), for: deck, context: modelContext, deckLoadingState: deckLoadingState)
                        dismiss()
                    }
                } else {
                    ErrorSelection = true
                }
                
            }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .foregroundStyle(Color("Text"))
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(1)
            .background(Color("LightAccent"))
            
        }
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color("LightAccent"),lineWidth: 2)
        )
        .alert("Select an input method", isPresented: $ErrorSelection) {
            Button("Ok", role: .cancel) { }
        }
    }
}

enum addMethod: String, CaseIterable, Equatable {
    case prompt = "Prompt"
    case text = "Text"
    case pdf = "PDF"
}

