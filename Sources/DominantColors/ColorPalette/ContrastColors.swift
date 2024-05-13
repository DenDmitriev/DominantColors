//
//  ContrastColors.swift
//
//
//  Created by Denis Dmitriev on 12.05.2024.
//

import CoreGraphics.CGColor

/// A simple structure used to represent color palettes.
public struct ContrastColors {
    
    /// The color that should be used as a background.
    public let background: CGColor
    
    /// The color that should be used as the primary detail. For example the main text.
    public let primary: CGColor
    
    /// The color that should be used as the secondary detail. For example text that isn't as important as the one represented by the primary property.
    public let secondary: CGColor?
    
    /// Initializes a coherent color palette based on the passed in colors.
    /// The colors should be sorted by order of importance, where the first color is the most important.
    /// This makes it easy to generate palettes from a collection of colors.
    ///
    /// - Parameters:
    ///   - orderedColors: The colors that will be used to generate the color palette. The first color is considered the most important one.
    ///   - darkBackground: Whether the color palette is required to have a dark background. If set to false, the background can be dark or bright.
    ///   - ignoreContrastRatio: Whether the color palette should ignore the contrast ratio between the different colors. It is recommended to set this value to `false` (default) if the color palette will be used to display text.
    public init?(orderedColors: [CGColor], darkBackground: Bool = true, ignoreContrastRatio: Bool = false) {
        guard orderedColors.count > 1 else {
            return nil
        }
        
        var backgroundColor: CGColor
        if darkBackground {
            guard let darkestOrderedColor = orderedColors.first(where: { color -> Bool in
                return color.relativeLuminance < 0.5
            }) else {
                return nil
            }
            backgroundColor = darkestOrderedColor
        } else {
            backgroundColor = orderedColors.first!
        }
        
        var primaryColor: CGColor?
        var secondaryColor: CGColor?
        if !ignoreContrastRatio {
            orderedColors.forEach { (color) in
                guard color != backgroundColor else { return }
                
                let contrastRatio = backgroundColor.contrastRatio(with: color)
                switch contrastRatio {
                case .acceptable, .acceptableForLargeText:
                    if primaryColor != nil {
                        secondaryColor = nil
                    } else {
                        primaryColor = color
                    }
                default:
                    return
                }
            }
        } else {
            orderedColors.forEach { (color) in
                guard color != backgroundColor else { return }
                if primaryColor == nil {
                    primaryColor = color
                } else {
                    secondaryColor = color
                }
            }
        }
        
        guard let primary = primaryColor else { return nil }
        self.background = backgroundColor
        self.primary = primary
        self.secondary = secondaryColor
    }
    
    /// Initializes a coherant color palette based on the passed in colors.
    /// This makes it easy to generate palettes from a collection of colors.
    ///
    /// - Parameters:
    ///   - colors: The colors that will be used to generate the color palette. The best colors will be selected to have a color palette with enough contrast. At least two colors should be passed in.
    ///   - darkBackground: Whether the color palette is required to have a dark background. If set to false, the background can be dark or bright.
    ///   - ignoreContrastRatio: Whether the color palette should ignore the contrast ratio between the different colors. It is recommended to set this value to `false` (default) if the color palette will be used to display text.
    public init?(colors: [CGColor], darkBackground: Bool = true, ignoreContrastRatio: Bool = false) {
        guard colors.count > 1 else {
            return nil
        }
        
        var darkestColor: CGColor?
        var brightestColor: CGColor?
        
        colors.forEach { (color) in
            if color.relativeLuminance < darkestColor?.relativeLuminance ?? .greatestFiniteMagnitude {
                darkestColor = color
            }
            
            if color.relativeLuminance > brightestColor?.relativeLuminance ?? .leastNormalMagnitude {
                brightestColor = color
            }
        }
        guard let darkestColor = darkestColor,
              let brightestColor = brightestColor
        else { return nil }
        
        if !ignoreContrastRatio {
            let backgroundPrimaryContrastRatio = darkestColor.contrastRatio(with: brightestColor)
            switch backgroundPrimaryContrastRatio {
            case .acceptable, .acceptableForLargeText:
                break
            default:
                return nil
            }
        }
        
        let backgroundColor = darkBackground ? darkestColor : brightestColor
        let primaryColor = darkBackground ? brightestColor : darkestColor
        
        let secondaryColor = colors.first { (color) -> Bool in
            if !ignoreContrastRatio {
                let backgroundColorConstratRatio = color.contrastRatio(with: backgroundColor)
                switch backgroundColorConstratRatio {
                case .acceptable , .acceptableForLargeText:
                    break
                default: return false
                }
            }
            
            let backgroundColorDifference = color.difference(from: backgroundColor)
            switch backgroundColorDifference {
            case .different, .far:
                let primaryColorDifference = color.difference(from: primaryColor)
                switch primaryColorDifference {
                case .near, .different, .far:
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }
        
        self.background = backgroundColor
        self.primary = primaryColor
        self.secondary = secondaryColor
    }
    
}
