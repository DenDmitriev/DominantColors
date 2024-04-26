//
//  ColorFrequency.swift
//  
//
//  Created by Denis Dmitriev on 23.04.2024.
//

import CoreGraphics.CGColor

/// A simple structure containing a color, and a frequency.
public class ColorFrequency: CustomStringConvertible, Hashable {
    
    let index: Int
    
    /// A simple `CGColor` instance.
    public var color: CGColor
    
    /// The frequency of the color.
    /// That is, how much it is present.
    public var frequency: CGFloat
    
    public var description: String {
        return "Color: \(color) - Frequency: \(frequency)"
    }
    
    init(index: Int, color: CGColor, count: CGFloat) {
        self.index = index
        self.frequency = count
        self.color = color
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    public static func == (lhs: ColorFrequency, rhs: ColorFrequency) -> Bool {
        lhs.index == rhs.index
    }
}
