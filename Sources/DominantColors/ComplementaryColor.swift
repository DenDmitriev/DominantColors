//
//  ComplementaryColor.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

extension CGColor {
    
    /// Computes the complementary color of the current color instance.
    /// Complementary colors are opposite on the color wheel.
    public var complementaryColor: CGColor {
        let red: CGFloat = (255.0 - red255) / 255.0
        let green: CGFloat = (255.0 - green255) / 255.0
        let blue: CGFloat = (255.0 - blue255) / 255.0
        
        let components: [CGFloat] = [red, green, blue, alpha]
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        let cgColor = CGColor(colorSpace: colorSpace, components: components) ?? self
        return cgColor
    }
    
}
