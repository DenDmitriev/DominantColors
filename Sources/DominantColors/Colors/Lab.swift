//
//  Lab.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

struct Lab {
    let L: CGFloat
    let a: CGFloat
    let b: CGFloat
}

struct LabCalculator {
    static func convert(RGB: RGB) -> Lab {
        let XYZ = XYZCalculator.convert(rgb: RGB)
        let Lab = LabCalculator.convert(XYZ: XYZ)
        return Lab
    }
    
    static let referenceX: CGFloat = 95.047
    static let referenceY: CGFloat = 100.0
    static let referenceZ: CGFloat = 108.883
    
    /// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_Lab.html
    static func convert(XYZ: XYZ) -> Lab {
        func transform(value: CGFloat) -> CGFloat {
            if value > pow(6/29, 3) {
                return pow(value, 1/3)
            } else {
                return (pow(29/3, 3) * value + 16) / 116
            }
        }
        
        let X = transform(value: XYZ.X / referenceX)
        let Y = transform(value: XYZ.Y / referenceY)
        let Z = transform(value: XYZ.Z / referenceZ)
        
        let L = ((116.0 * Y) - 16.0).rounded(.toNearestOrAwayFromZero, precision: 10000)
        let a = (500.0 * (X - Y)).rounded(.toNearestOrAwayFromZero, precision: 10000)
        let b = (200.0 * (Y - Z)).rounded(.toNearestOrAwayFromZero, precision: 10000)
        
        return Lab(L: L, a: a, b: b)
    }
}

extension CGColor {
    
    /// The L* value of the CIELAB color space.
    /// L* represents the lightness of the color from 0 (black) to 100 (white).
    public var L: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.L
    }
    
    /// The a* value of the CIELAB color space.
    /// a* represents colors from green to red.
    public var a: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.a
    }
    
    /// The b* value of the CIELAB color space.
    /// b* represents colors from blue to yellow.
    public var b: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.b
    }
    
}
