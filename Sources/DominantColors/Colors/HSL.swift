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
    
    var cgColor: CGColor {
        HSLCalculator.convert(hue: hue, saturation: saturation, lightness: lightness)
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
    
    /// Convert HSL to CGColor color
    /// Converts an HSL color value to RGB. .
    /// Assumes h, s, and l are contained in the set [0, 1] and returns RGB in the set [0, 255].
    ///
    /// - Parameters:
    ///     - HUE: 0...360 degree in color circle.
    ///     - Saturation: 0...100 percent.
    ///     - Lightness: 0...100 percent..
    ///
    ///  - Returns:`CGColor` color in sRGB color space.
    ///
    /// [Conversion formula.](http://en.wikipedia.org/wiki/HSL_color_space)
    static func convert(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> CGColor {
        guard saturation != .zero else {
            let ligtness = lightness / 100
            return CGColor(srgbRed: ligtness, green: ligtness, blue: ligtness, alpha: 1.0)
        }
        
        let hue = hue / 360
        let saturation = saturation / 100
        let lightness = lightness / 100
        
        let q = lightness < 0.5 ? lightness * (1 + saturation) : lightness + saturation - lightness * saturation
        let p = 2 * lightness - q
        let r = hue2rgb(p, q, hue + 1/3)
        let g = hue2rgb(p, q, hue)
        let b = hue2rgb(p, q, hue - 1/3)
        
        return CGColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// Converts an HUE to red, green or blue.
    ///  - Returns: `CGFloat` in 0...1.
    static private func hue2rgb(_ p: CGFloat, _ q: CGFloat, _ t: CGFloat) -> CGFloat {
        var t = t
        
        if t < 0 { t += 1 }
        if t > 1 { t -= 1 }
        
        if t < 1/6 {
            return p + (q - p) * 6 * t
        }
        
        if t < 1/2 {
            return q
        }
        
        if t < 2/3 {
            return p + (q - p) * (2/3 - t) * 6
        }
        
        return p
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
