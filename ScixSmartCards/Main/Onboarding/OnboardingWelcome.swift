//
//  OnboardingWelcome.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI

struct OnboardingWelcome: View {
    @State private var header: Bool = false
    @State private var subheader: Bool = false
    @State private var button: Bool = false
    
    var body: some View {
        VStack {
            
            Spacer()
            VStack{
                if header {
                    Text("Scix")
                        .font(.system(size: 180, weight: .bold))
                        .foregroundStyle(Color("Text"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .padding(.horizontal)
                        .transition(.scale(scale: 0, anchor: .bottom))
                }
                if subheader {
                    Text("Smartcards made smarter")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.scale(scale: 0, anchor: .bottom))
                    
                }
            }
            Spacer()
            
            if button {
                Button(action: {

                }) {
                    Text("Get Started")
                        .font(.headline)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .onAppear{
            animatedisplay()
        }
    }
    private func animatedisplay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.spring().delay(1)) {
                header = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(Animation.spring().delay(1)) {
                subheader = true
                button = true

            }
        }
        
    }
    
    
}
