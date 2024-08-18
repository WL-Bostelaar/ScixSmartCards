//
//  CustomGauge.swift
//  Scix
//
//  Created by William Bostelaar on 21/6/2024.
//

import SwiftUI

struct CustomGauge<Content: View>: GaugeStyle {
    var content: Content

    private var gradient = LinearGradient(
        colors:
          [
            Color.red,
            Color.orange
          ],
        startPoint: .trailing,
        endPoint: .leading
      )
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
      }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
          ZStack {
            content
                  .frame(alignment: .center)
            
            Circle()
              .trim(from: 0, to: configuration.value * 0.75)
              .stroke(gradient, style: StrokeStyle(lineWidth: 30, lineCap: .round))
              .rotationEffect(.degrees(135))
              .frame(width: 220, height: 250)
          }
          
          configuration.currentValueLabel
            .fontWeight(.bold)
            .font(.title2)
            .foregroundColor(Color("Background"))
        }
      }
    }

