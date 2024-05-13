//
//  NSImageExtension.swift
//
//
//  Created by Denis Dmitriev on 12.05.2024.
//

#if os(OSX)
import AppKit

extension NSImage {
    /// Get the dominant colors of the image.
    ///
    /// Finds the primary colors in an image using color difference formulas.
    /// This avoids having to deal with many shades of the same colors, which often happens when dealing with compression artifacts (jpegs, etc.).
    /// - Parameters:
    ///  - count: the maximum number of colors to extract for the image.
    ///  - options: additional options for extracted colors..
    /// - Returns: colors as an array of `NSColor` instances.
    public func dominantColors(max count: Int = 8, options: [DominantColors.Options] = []) throws -> [NSColor] {
        try DominantColors.dominantColors(nsImage: self, maxCount: count, options: options)
    }
    
    /// Initializes contrast colors from the passed colors.
    /// Colors should be sorted by importance, with the first color being the most important.
    /// This makes it easy to create palettes from a collection of colors.
    ///
    /// - Parameters:
    ///   - darkBackground: Whether the color palette should have a dark background. If set to false, the background can be dark or bright.
    ///   - ignoreContrastRatio: Whether the color palette should ignore the contrast ratio between different colors. It is recommended to set this value to false (the default) if the color palette will be used to display text.
    public func contrastColors(darkBackground: Bool = true, ignoreContrastRatio: Bool = false) -> ContrastColors? {
        guard let dominantColors = try? self.dominantColors() else { return nil }
        let contrastColors = ContrastColors(orderedColors: dominantColors.map({ $0.cgColor }), darkBackground: darkBackground, ignoreContrastRatio: ignoreContrastRatio)
        return contrastColors
    }
}
#endif
