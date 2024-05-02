//
//  XYZ.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

struct XYZ {
    let X: CGFloat
    let Y: CGFloat
    let Z: CGFloat
}

struct XYZCalculator {
    
    static func convert(rgb: RGB) -> XYZ {
        func transform(value: CGFloat) -> CGFloat {
            if value > 0.04045 {
                return pow((value + 0.055) / 1.055, 2.4)
            } else {
                return value / 12.92
            }
        }
        
        let red = transform(value: rgb.R) * 100.0
        let green = transform(value: rgb.G) * 100.0
        let blue = transform(value: rgb.B) * 100.0
        
        let X = (red * 0.4124564 + green * 0.3575761 + blue * 0.1804375).rounded(.toNearestOrAwayFromZero, precision: 10000)
        let Y = (red * 0.2126729 + green * 0.7151522 + blue * 0.0721750).rounded(.toNearestOrAwayFromZero, precision: 10000)
        let Z = (red * 0.0193339 + green * 0.1191920 + blue * 0.9503041).rounded(.toNearestOrAwayFromZero, precision: 10000)

        return XYZ(X: X, Y: Y, Z: Z)
    }
    
}

extension CGColor {
    
    /// The X value of the XYZ color space.
    public var X: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.X
    }
    
    /// The Y value of the XYZ color space.
    public var Y: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.Y
    }
    
    /// The Z value of the XYZ color space.
    public var Z: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.Z
    }
    
}
