//
//  ColorFrequency.swift
//  
//
//  Created by Denis Dmitriev on 23.04.2024.
//

import CoreGraphics.CGColor

/// A simple structure containing a color, and a frequency.
public class ColorFrequency: CustomStringConvertible {
    /// A simple `CGColor` instance.
    public var color: CGColor
    
    /// The frequency of the color.
    ///
    /// Shows how many times a color is present in an image.
    public var frequency: CGFloat
    
    /// Parameter of color importance by frequency and normal brightness.
    ///
    /// Calculated based on their human sensitivity to normal color multiplied by the number of `frequency` pixels of this color in the image,
    /// where normal means an average brightness of 50% and saturation of 75% in HSL color.
    /// The closer the brightness is to 50% in HSL color, the greater the coefficient will be. Lighter or darker colors will produce a lower ratio.
    /// The closer the saturation is to 75% in an HSL color, the higher the coefficient will be. Paler or oversaturated colors will produce a lower ratio.
    /// For example, a color HSL(0, 75, 50) with a frequency of 100 pixels in an image will receive `100 * 1 * 1 = 100`.
    public var normal: CGFloat {
        return frequency * normalLightnessFactor * normalSaturationFactor
    }
    
    public var shade: ColorShade
    
    public var description: String {
        return "Color: \(shade.title) (\(color)) - Frequency: \(frequency)"
    }
    
    init(color: CGColor, count: CGFloat) {
        self.frequency = count
        self.color = color
        self.shade = ColorShade(cgColor: color)
    }
    

    /// Normal brightness parameter.
    ///
    /// Has a size from 0 to 1.
    ///
    /// Calculated based on their sensitivity to normal color brightness by a person.
    /// Normal brightness is assumed to be 50% brightness in HSL color.
    /// The closer the brightness is to 50% in HSL color, the greater the coefficient will be. Very light or dark colors will give a lower ratio.
    /// For example, the color `HSL(0, 75, 50)` will receive `1`, and the `HSL(0, 25, 75)` color will receive `0.5`.
    var normalLightnessFactor: CGFloat {
        let lightnessFactor: CGFloat
        if color.lightness >= 50 {
            lightnessFactor = (50 - (color.lightness - 50)) / 50
        } else {
            lightnessFactor = (50 - (50 - color.lightness)) / 50
        }
        return lightnessFactor.rounded(.toNearestOrAwayFromZero, precision: 100)
    }
    
    /// Normal saturation parameter.
    ///
    /// Has a size from 0 to 1.
    ///
    /// Calculated based on their susceptibility to normal human color saturation.
    /// Normal saturation is assumed to be 75% saturation in HSL color.
    /// The closer the saturation is to 75% in an HSL color, the higher the coefficient will be. Paler or oversaturated colors will produce a lower ratio.
    /// For example, the color `HSL(0, 75, 50)` will receive `1`, and the `HSL(0, 25, 75)` color will receive `0.33`.
    var normalSaturationFactor: CGFloat {
        let saturationFactor: CGFloat
        if color.saturation >= 75 {
            saturationFactor = (75 - (color.saturation - 75)) / 75
        } else {
            saturationFactor = (75 - (75 - color.saturation)) / 75
        }
        return saturationFactor.rounded(.toNearestOrAwayFromZero, precision: 100)
    }
}

extension ColorFrequency: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color.hashValue + Int(frequency))
    }
    
    public static func == (lhs: ColorFrequency, rhs: ColorFrequency) -> Bool {
        lhs.color == rhs.color &&
        lhs.frequency == rhs.frequency
    }
}
