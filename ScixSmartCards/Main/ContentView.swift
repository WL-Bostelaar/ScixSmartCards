//
//  ContentView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("onboarded") var onboarded: Bool = false
    @State var selectedTab: Int = 0
    @State var path = NavigationPath()
    @State var currentview: Int = 0
    @State private var selection: Option?
    
    //Sizing
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIpad: Bool { verticalSizeClass == .regular && horizontalSizeClass == .regular}
    var isIphonePortrait: Bool { verticalSizeClass == .regular && horizontalSizeClass == .compact}
    var isIphoneHorizontal: Bool { verticalSizeClass == .compact && horizontalSizeClass == .compact}
    
    var body: some View {
        if !onboarded{
            OnboardingView()
        } else {
            if isIphonePortrait {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        
                        DeckView()
                    }
                    .tabItem {
                        Image(systemName: "square.stack")
                    }
                    .tag(0)
                    
                    NavigationView {
                        GameEntryView()
                    }
                    .tabItem {
                        Image(systemName: "play.fill")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(Color.orange)
                            .foregroundColor(Color.white)
                            .clipShape(Circle())
                    }
                    .tag(1)
                    
                    NavigationView {
                        StatsView()
                    }
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis.ascending")
                    }
                    .tag(2)
                }
            } else {
                NavigationSplitView {
                    List(selection: $selection) {
                        NavigationLink(value: Option.one) {
                            Label("Decks", systemImage: "square.stack")
                        }
                        NavigationLink(value: Option.two) {
                            Label("Play", systemImage: "play.fill")
                        }
                        NavigationLink(value: Option.three) {
                            Label("Stats", systemImage: "chart.bar.xaxis.ascending")
                        }
                        NavigationLink(value: Option.four) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle("Navigation")
                    
                } detail: {
                    switch selection {
                    case .none:
                        NavigationStack {
                            DeckView()
                        }
                    case .one:
                        NavigationStack {
                            DeckView()
                        }
                    case .two:
                        NavigationStack {
                            GameEntryView()
                        }
                    case .three:
                        NavigationStack {
                            StatsView()
                        }
                    case .four:
                        NavigationStack {
                            SettingsView()
                        }
                        
                    }
                }
            }
        }
    }
}

enum Option: String, Equatable, Identifiable, Hashable {
    
    case one
    case two
    case three
    case four
    
    var id: Option { self }
    
}


