//
//  RelativeLuminance.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

extension CGColor {
    
    /// Computes the relative luminance of the color.
    /// This assume that the color is using the sRGB color space.
    /// This is the relative brightness, normalized where 0 is black and 1 is white.
    public var relativeLuminance: CGFloat {
        func toLinear(colorAttribute: CGFloat) -> CGFloat {
            if colorAttribute <= 0.03928 {
                return colorAttribute / 12.92
            } else {
                return pow((colorAttribute + 0.055) / 1.055, 2.4)
            }
        }
        
        let linearR = toLinear(colorAttribute: red)
        let linearG = toLinear(colorAttribute: green)
        let linearB = toLinear(colorAttribute: blue)
        
        let relativeLuminance = 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB
        
        return relativeLuminance.rounded(.toNearestOrAwayFromZero, precision: 1000)
    }
    
}
