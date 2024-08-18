//
//  FlowLayout.swift
//  ScixSmartCards
//
//  Created by William Bostelaar on 20/7/2024.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // accept the full proposed space, replacing any nil values with a sensible default
        proposal.replacingUnspecifiedDimensions()
    }
    
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map {$0.sizeThatFits(.unspecified)}
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }
        return maxSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        
        let horizontalbounds: CGFloat = bounds.size.width
        
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        
        let maxSize = maxSize(subviews: subviews)
        
        for index in subviews.indices {
            
            let size = subviews[index].sizeThatFits(.unspecified)
            
            //Start
            if index == 0 {
                x = bounds.minX
                y = bounds.minY + maxSize.height/2
            } else {
                if (x + size.width) > horizontalbounds {
                    x = bounds.minX
                    y = y + maxSize.height + spacing
                }
            }
            
            let point = CGPoint(x: x, y: y)
            
            subviews[index].place(at: point, anchor: .leading, proposal: .unspecified)
            x = x + size.width + spacing
        }
    }
    
}
