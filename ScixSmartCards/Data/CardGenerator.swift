//
//  CardGenerator.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import Combine
import SwiftData
import PDFKit

struct APIResponse: Codable {
    let body: String
    let statusCode: Int
}

struct BodyResponse: Codable {
    let cards: [CardResponse]
}

struct CardResponse: Codable {
    let questiontype: String
    let question: String
    let answer: String
    let wronganswers: [String]
    let difficulty: Int
}

func generateCards(messagetext: String, addmethod: addMethod, numberOfCards: Int, for deck: Deck, context: ModelContext, deckLoadingState: DeckLoadingState) {
    //Determine cards to generate
    var url: URL = URL(string: "https://ahjivc5gxf.execute-api.ap-southeast-2.amazonaws.com/Dev")!
    if addmethod == .prompt {
        url = URL(string: "https://ahjivc5gxf.execute-api.ap-southeast-2.amazonaws.com/Dev/generate-cards")!
    } else if addmethod == .text || addmethod == .pdf {
        url = URL(string: "https://ahjivc5gxf.execute-api.ap-southeast-2.amazonaws.com/Dev/generate_note_cards")!
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "messages": "\(numberOfCards) cards about \(messagetext)"
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        print("Error serializing JSON: \(error)")
        return
    }
    
    DispatchQueue.main.async {
        deckLoadingState.setLoading(for: deck.id, isLoading: true)
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error making POST request: \(error)")
            DispatchQueue.main.async {
                deckLoadingState.setLoading(for: deck.id, isLoading: false)
            }
            return
        }
        


        guard let data = data else {
            print("No data received")
            DispatchQueue.main.async {
                deckLoadingState.setLoading(for: deck.id, isLoading: false)
            }
            return
        }

        do {
            // Decode the initial API response
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            print("API Response: \(apiResponse)")

            // Decode the body string into an array of CardResponse
            guard let bodyData = apiResponse.body.data(using: .utf8) else {
                print("Error converting body string to data")
                return
            }

            let cardsWrapper = try JSONDecoder().decode(BodyResponse.self, from: bodyData)
            let cardResponses = cardsWrapper.cards
            print("Card Responses: \(cardResponses)")

            DispatchQueue.main.async {
                for cardResponse in cardResponses {
                    
                    if cardResponse.questiontype == "Multiple Choice" {
                        let card = Card(
                            questiontype: cardResponse.questiontype,
                            question: cardResponse.question,
                            answer: cardResponse.answer,
                            wronganswers: cardResponse.wronganswers,
                            deck: deck,
                            creationDate: Date(),
                            learnfactor: Double(cardResponse.difficulty),
                            difficulty: cardResponse.difficulty
                        )
                        context.insert(card)
                        deck.cards.append(card)
                        print(card.questiontype, deck.name, card.answer)
                    } else {
                        let card = Card(
                            questiontype: cardResponse.questiontype,
                            question: cardResponse.question,
                            answer: cardResponse.answer,
                            deck: deck,
                            creationDate: Date(),
                            learnfactor: Double(cardResponse.difficulty),
                            difficulty: cardResponse.difficulty
                        )
                        context.insert(card)
                        deck.cards.append(card)
                        print(card.questiontype, deck.name, card.answer)
                    }
                }
                try? context.save()
                DispatchQueue.main.async {
                    deckLoadingState.setLoading(for: deck.id, isLoading: false)
                }
            }
        } catch {
            print("Error decoding JSON: \(error)")
            DispatchQueue.main.async {
                deckLoadingState.setLoading(for: deck.id, isLoading: false)
            }
        }
    }.resume()
    print("END OF CARD GEN")
}

//MARK: PDF

func pdfreader(PDFDoc: PDFDocument, addmethod: addMethod, numberOfCards: Int, for deck: Deck, context: ModelContext, deckLoadingState: DeckLoadingState) {
    
    let pageCount = PDFDoc.pageCount
    let documentContent = NSMutableAttributedString()
    
    for i in 0 ..< pageCount {
        guard let page = PDFDoc.page(at: i) else { continue }
        guard let pageContent = page.attributedString else { continue }
        documentContent.append(pageContent)
    }
        
    let paragraphs = documentContent.string.components(separatedBy: "\n\n")
    
    var wordCount = 0
    var currentChunk = ""
    
    print("Starting split")
    print(documentContent.string.split(separator: " ").count)
    
    for paragraph in paragraphs {
        let paragraphWordCount = paragraph.split(separator: " ").count
        
        if wordCount + paragraphWordCount > 2000 {
            // Pass the current chunk to another function
            print("Chunk")
            print(currentChunk)
            print(currentChunk.split(separator: " ").count)
            print("Starting Gen")
            
            generateCards(messagetext: currentChunk, addmethod: .pdf, numberOfCards: numberOfCards, for: deck, context: context, deckLoadingState: deckLoadingState)
            
            // Reset for the next chunk
            currentChunk = paragraph
            wordCount = paragraphWordCount
        } else {
            currentChunk += "\n\n" + paragraph
            wordCount += paragraphWordCount
        }
        if !currentChunk.isEmpty {
            print("Starting Last Gen")
            print("Chunk")
            print(currentChunk)
            print(currentChunk.split(separator: " ").count)
            
            generateCards(messagetext: currentChunk, addmethod: .pdf, numberOfCards: numberOfCards, for: deck, context: context, deckLoadingState: deckLoadingState)
        }
        print("END OF PDF READ")
    }
}
