//
//  StatsView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query var decks: [Deck]
    
    //Sizing
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIpad: Bool { verticalSizeClass == .regular && horizontalSizeClass == .regular}
    
    var body: some View {
            ScrollView {
                if !isIpad {
                    TabView {
                        VStack {
                            Text("Learning Factor")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            
                            OverviewChart(decks: decks)
                                .padding()
                                .background(Color("Overlay"))
                                .cornerRadius(15)
                        }
                        .frame(height: 250)
                        .padding()
                        
                        VStack {
                            Text("Daily Play Time")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding(.top)
                            
                            TimeKeeperView()
                                .padding()
                                .background(Color("Overlay"))
                                .cornerRadius(15)
                            
                        }
                        .frame(height: 250)
                        .padding()
                        .offset(y: -8)
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 280, alignment: .bottom)
                    
                } else {
                    HStack {
                        VStack {
                            Text("Learning Factor")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            
                            OverviewChart(decks: decks)
                                .padding()
                                .background(Color("Overlay"))
                                .cornerRadius(15)
                        }
                        .frame(height: 250)
                        .padding()
                        VStack {
                            Text("Daily Play Time")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(Color("Text"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding(.top)
                            
                            TimeKeeperView()
                                .padding()
                                .background(Color("Overlay"))
                                .cornerRadius(15)
                            
                        }
                        .frame(height: 250)
                        .padding()
                        .offset(y: -8)
                    }
                }
                
                Text("Decks")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.top)
                
                //Add foreach for decks
                VStack {
                    ForEach(decks) { deck in
                        StatDeckTileView(deck: deck)
                    }
                }
                // Add other statistics views here as needed
            }
            .padding()
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
        }
    }
