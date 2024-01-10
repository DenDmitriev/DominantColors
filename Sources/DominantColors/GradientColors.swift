//
//  GradientColors.swift
//
//
//  Created by Denis Dmitriev on 03.12.2023.
// https://stackoverflow.com/questions/15032562/ios-find-color-at-point-between-two-colors
//

#if canImport(UIKit)
import UIKit
#endif

import CoreGraphics.CGColor

extension Array where Element == CGColor {
    public func gradientColor(percent: CGFloat) -> CGColor {
        let percentage: CGFloat = Swift.max(Swift.min(percent, 100), 0) / 100
        switch percentage {
        case 0:
            return first ?? .clear
        case 1:
            return last ?? .clear
        default:
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            
            let firstColor = self[firstIndex]
            let secondColor = self[secondIndex]
            
            let (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (
                firstColor.components?[0] ?? .zero,
                firstColor.components?[1] ?? .zero,
                firstColor.components?[2] ?? .zero,
                firstColor.components?[3] ?? .zero
            )
            let (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (
                secondColor.components?[0] ?? .zero,
                secondColor.components?[1] ?? .zero,
                secondColor.components?[2] ?? .zero,
                secondColor.components?[3] ?? .zero
            )
            
            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            
            let cgColor = CGColor(
                red: CGFloat(red1 + (red2 - red1) * intermediatePercentage),
                green: CGFloat(green1 + (green2 - green1) * intermediatePercentage),
                blue: CGFloat(blue1 + (blue2 - blue1) * intermediatePercentage),
                alpha: CGFloat(alpha1 + (alpha2 - alpha1) * intermediatePercentage)
            )
            
            return cgColor
        }
    }
    
    public func gradientColor(at point: CGFloat, size: CGFloat) -> CGColor {
        guard point <= size,
              point >= 1,
              size >= 2,
              count >= 2
        else { return .clear }
        
        switch point {
        case 1:
            return first ?? .clear
        case size:
            return last ?? .clear
        default:
            let percentage: CGFloat = (point - 1) / (size - 1)
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            
            let firstColor = self[firstIndex]
            let secondColor = self[secondIndex]
            
            let (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (
                firstColor.components?[0] ?? .zero,
                firstColor.components?[1] ?? .zero,
                firstColor.components?[2] ?? .zero,
                firstColor.components?[3] ?? .zero
            )
            let (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (
                secondColor.components?[0] ?? .zero,
                secondColor.components?[1] ?? .zero,
                secondColor.components?[2] ?? .zero,
                secondColor.components?[3] ?? .zero
            )
            
            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            
            let cgColor = CGColor(
                red: CGFloat(red1 + (red2 - red1) * intermediatePercentage),
                green: CGFloat(green1 + (green2 - green1) * intermediatePercentage),
                blue: CGFloat(blue1 + (blue2 - blue1) * intermediatePercentage),
                alpha: CGFloat(alpha1 + (alpha2 - alpha1) * intermediatePercentage)
            )
            
            return cgColor
        }
    }
    
    public func gradientColors(in size: CGFloat) -> Self {
        var result: Self = []
        for point in 1...Int(size) {
            let color = self.gradientColor(at: CGFloat(point), size: size)
            result.append(color)
        }
        return result
    }
}

#if canImport(UIKit)
extension CGColor {
    fileprivate static var clear: CGColor { UIColor.clear.cgColor }
}
#endif

