//
//  Hex.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

public struct Hex {
    
    let cgColor: CGColor
    
    /// Default init with CGColor
    public init(cgColor: CGColor) {
        self.cgColor = cgColor
    }
    
    /// Convenience initializer with hexadecimal values.
    public init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var hexValue = UInt64()
        
        guard Scanner(string: hexString).scanHexInt64(&hexValue) else {
            return nil
        }
        
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // 0xRGB
            (a, r, g, b) = (255, (hexValue >> 8) * 17, (hexValue >> 4 & 0xF) * 17, (hexValue & 0xF) * 17)
        case 6: // 0xRRGGBB
            (a, r, g, b) = (255, hexValue >> 16, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        case 8: // 0xRRGGBBAA
            (r, g, b, a) = (hexValue >> 24, hexValue >> 16 & 0xFF, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        let red = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue = CGFloat(b) / 255
        let alpha = CGFloat(a) / 255
        
        let components: [CGFloat] = [red, green, blue, alpha]
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        
        self.cgColor = CGColor(colorSpace: colorSpace!, components: components)!
    }
    
    /// The hexadecimal value of the color.
    public var hex: String {
        let rgb: Int = (Int)(cgColor.red * 255) << 16 | (Int)(cgColor.green * 255) << 8 | (Int)(cgColor.blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
    
}
