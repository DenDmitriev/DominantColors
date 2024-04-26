//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 05.09.2023.
//

import CoreImage

public struct HSL {
    let hue: Double
    let saturation: Double
    let lightness: Double
    
    init?(cgColor: CGColor) {
        let red = UInt8(cgColor.red255)
        let green = UInt8(cgColor.green255)
        let blue = UInt8(cgColor.blue255)
        
        let hsl = HSLCalculator.convert(red: red, green: green, blue: blue)
        
        self.hue = hsl.hue
        self.saturation = hsl.saturation
        self.lightness = hsl.lightness
    }
    
    init(hue: Double, saturation: Double, lightness: Double) {
        self.hue = hue
        self.saturation = saturation
        self.lightness = lightness
    }
}

struct HSLCalculator {
    
    /// Input RGB color with 0...255 color channels
    static func convert(red: UInt8, green: UInt8, blue: UInt8) -> HSL {
        let red = Double(red)
        let green = Double(green)
        let blue = Double(blue)
        let minColor = min(red, green, blue)
        let maxColor = max(red, green, blue)

        let lightness = 1/2 * (maxColor + minColor) / 255.0

        let delta = (maxColor - minColor) / 255.0

        let saturation: Double
        
        switch lightness {
        case 0:
            saturation = 0.0
        case 1:
            saturation = 0.0
        default:
            saturation = delta / (1 - abs(2 * lightness - 1))
        }

        let hue: Double
        if (delta == 0) {
            hue = 0
        } else {
            switch(maxColor) {
            case red:
                let segment = (green - blue) / (delta * 255)
                var shift = 0 / 60.0 // R° / (360° / hex sides)
                if segment < 0 { // hue > 180, full rotation
                    shift = 360 / 60 // R° / (360° / hex sides)
                }
                hue = segment + shift
            case green:
                let segment = (blue - red) / (delta * 255)
                let shift   = 120.0 / 60.0 // G° / (360° / hex sides)
                hue = segment + shift
            case blue:
                let segment = (red - green) / (delta * 255)
                let shift   = 240.0 / 60.0 // B° / (360° / hex sides)
                hue = segment + shift
            default:
                hue = .zero
            }
        }
        
        return HSL(hue: hue * 60, saturation: saturation * 100, lightness: lightness * 100)
    }
}

extension CGColor {
    public var hue: CGFloat {
        return hsl.hue
    }
    public var saturation: CGFloat {
        return hsl.saturation
    }
    public var lightness: CGFloat {
        return hsl.lightness
    }
    
    var hsl: HSL {
        return HSLCalculator.convert(red: UInt8(self.red255), green: UInt8(self.green255), blue: UInt8(self.blue255))
    }
}
