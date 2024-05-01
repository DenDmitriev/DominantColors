//
//  DominantColors.swift
//
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import CoreImage

public class DominantColors {
    /// Extract the dominant colors of the image.
    ///
    /// All colors are combined together based on similarity.
    /// This avoids having to deal with many shades of the same colors, which often happens when dealing with compression artifacts (jpegs, etc.).
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    ///  - algorithm: The algorithm used to determine the dominant colors. When using a k-means algorithm (`kMeansClustering`), a `CIKMeans` CIFilter isused. Unfortunately this filter doesn't work on the simulator.
    ///  - maxCount: Maximum number of colors for the image.
    ///  - options: Some of additional options for removing flowers.
    ///  - sorting: Type of sorting sequence colors.
    ///  - deltaColors: Only used for CIE76, CIE94, CIEDE2000, CMC algorithms. The score that needs to be met to consider two colors similar. The larger the value, the fewer shades will be obtained from the images
    ///     - 10 by default to match similar shades
    ///     - 2.3 approximately corresponds to the minimum difference between colors visible to the human eye.
    /// - Returns: The dominant colors as array of `CGColor` instances. When using the `.iterative` algorithm, this array is ordered where the first color is the most dominant one.
    public static func dominantColors(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        algorithm: DominantColorAlgorithm = .iterative(formula: .CIE76),
        maxCount: Int = 8,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        time log: Bool = false
    ) throws -> [CGColor] {
        switch algorithm {
        case .iterative(let formula):
            let dominantColorFrequencies = try dominantColorFrequencies(
                image: image,
                with: quality,
                using: formula,
                dominationColors: maxCount,
                flags: options,
                sorting: sorting,
                deltaColors: deltaColors,
                time: log
            )
            let dominantColors = dominantColorFrequencies.map { $0.color }
            return dominantColors
        case .kMeansClustering:
            let dominantColors = try kMeansClustering(image: image, with: quality, sorting: sorting)
            return dominantColors
        case .areaAverage(let count):
            let dominantColors = try areaAverageColors(image: image, count: count, sorting: sorting)
            return dominantColors
        }
    }
    
    /// Enum of additional options for removing flowers.
    public enum Options {
        /// Remove pure black colors
        case excludeBlack
        /// Remove pure white colors
        case excludeWhite
        /// Remove pure gray colors
        case excludeGray
    }
    
    /// Color sorting options.
    public enum Sort: CaseIterable, Identifiable {
        /// Sorting colors from darkness to lightness.
        case darkness
        /// Sorting colors from lightness to darkness.
        case lightness
        /// Sorting colors by frequency in image.
        case frequency
        
        public var name: String {
            switch self {
            case .darkness:
                "Darkness"
            case .lightness:
                "Lightness"
            case .frequency:
                "Frequency"
            }
        }
        
        public var id: String {
            self.name
        }
    }
}
