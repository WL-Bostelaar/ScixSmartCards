//
//  OnboardingView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboarded") var onboarded: Bool = false
    @State private var currentTab: Int = 0
    @State private var geometrywidth: Int = 0
    @State private var currentoffset: Int = 0
    
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentTab) {
                OnboardingWelcome()
                    .tag(0)
                
                OnboardingDecks()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background {
                Image("OnboardingBackgroundB")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .offset()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        onboarded = true
                    }
                }
            }
        }
    }
}

