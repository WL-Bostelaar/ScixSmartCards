//
//  SideBarView.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//


import SwiftUI

struct SideBarView: View {
    @Binding var currentview: Int

    var body: some View {
        List {
            Button(action: {
                currentview = 0
            }) {
                Label("Decks", systemImage: "square.stack")
            }
            Button(action: {
                currentview = 1
            }) {
                Label("Play", systemImage: "play.fill")
            }
            Button(action: {
                currentview = 2
            }) {
                Label("Stats", systemImage: "chart.bar.xaxis.ascending")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Navigation")
    }
}
