//
//  DominantColors+ColorResolved.swift
//
//
//  Created by Denis Dmitriev on 11.05.2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DominantColors {
    
    /// Extract the dominant colors of the image.
    ///
    /// All colors are combined together based on similarity.
    /// This avoids having to deal with many shades of the same colors, which often happens when dealing with compression artifacts (jpegs, etc.).
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    ///  - algorithm: The different algorithms for comparing colors.
    ///  - maxCount: Maximum number of colors for the image.
    ///  - options: Some of additional options for removing flowers.
    ///  - sorting: Type of sorting sequence colors.
    ///  - deltaColors: The score that needs to be met to consider two colors similar. The larger the value, the fewer shades will be obtained from the images
    ///     - 10 by default to match similar shades
    ///     - 2.3 approximately corresponds to the minimum difference between colors visible to the human eye.
    ///  - resultLog: Prints a transcript of the results with the total time and number of colors to the console for debug.
    ///  - timeLog: Prints each step of the algorithm with time to the console for debug.
    /// - Returns: The dominant colors as array of `Color.Resolved` instances.
    public static func dominantColorsResolved(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        algorithm: DeltaEFormula = .CIE76,
        maxCount: Int = 8,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        resultLog: Bool = false,
        timeLog: Bool = false
    ) throws -> [Color.Resolved] {
        let colorFrequencies = try Self.dominantColorFrequencies(
            image: image,
            quality: quality,
            formula: algorithm,
            maxCount: maxCount,
            options: options,
            sorting: sorting,
            deltaColors: deltaColors,
            resultLog: resultLog,
            timeLog: timeLog
        )
        let dominantColors = colorFrequencies.map { cgColor2Resolved(cgColor: $0.color)}
        return dominantColors
    }
    
    /// Extract the dominant colors of the image.
    ///
    /// Finds the dominant colors of an image by using using a area average algorithm with CIAreaAverage filter.
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - count: Number of colors for the image.
    ///  - sorting: Type of sorting sequence colors.
    /// - Returns: Average colors, specified as an array of `Color.Resolved` instances.
    public static func averageColorsResolved(
        image: CGImage,
        count: Int = 8,
        sorting: Sort = .frequency
    ) throws -> [Color.Resolved] {
        let averageColors = try areaAverageColors(image: image, count: UInt8(count), sorting: sorting)
            .map { cgColor2Resolved(cgColor: $0)}
        return averageColors
    }
    
    /// Extract the dominant colors of the image.
    ///
    /// Finds the dominant colors of an image by using using a k-means clustering algorithm.
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - count: Number of colors for the image.
    ///  - sorting: Type of sorting sequence colors.
    /// - Returns: Cluster average colors as an array of `Color.Resolved` instances.
    public static func kMeansClusteringColorsResolved(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        count: Int = 8,
        sorting: Sort = .frequency
    ) throws -> [Color.Resolved] {
        let clusteringColors = try kMeansClustering(image: image, with: quality, count: count, sorting: sorting)
            .map { cgColor2Resolved(cgColor: $0)}
        return clusteringColors
    }
    
    private static func cgColor2Resolved(cgColor: CGColor) -> Color.Resolved {
        Color.Resolved(
            colorSpace: .sRGB,
            red: Float(cgColor.red),
            green: Float(cgColor.green),
            blue: Float(cgColor.blue),
            opacity: Float(cgColor.alpha))
    }
}

