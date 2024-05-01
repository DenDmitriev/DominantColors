//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 26.04.2024.
//

import CoreGraphics.CGColor

struct RGB255: Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
}

extension RGB255 {
    func cgColor(colorSpace: CGColorSpace) -> CGColor {
        let red = (CGFloat(red) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
        let green = (CGFloat(green) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
        let blue = (CGFloat(blue) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
        let alpha = 255.0
        let components: [CGFloat] = [red, green, blue, alpha]
        
        return CGColor(colorSpace: colorSpace, components: components) ?? CGColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
    }
}
