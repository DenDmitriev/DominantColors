//
//  DominantColors+NSColor.swift
//  
//
//  Created by Denis Dmitriev on 11.05.2024.
//

#if os(OSX)
import AppKit

@available(macOS 10.8, *)
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
    public static func dominantColors(
        nsImage: NSImage,
        quality: DominantColorQuality = .fair,
        algorithm: DeltaEFormula = .CIE76,
        maxCount: Int = 8,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        resultLog: Bool = false,
        timeLog: Bool = false
    ) throws -> [NSColor] {
        let cgImage = try cgImage(from: nsImage)
        let colorFrequencies = try dominantColorFrequencies(
            image: cgImage,
                    quality: quality,
            formula: algorithm,
            maxCount: maxCount,
            options: options,
            sorting: sorting,
            deltaColors: deltaColors,
            resultLog: resultLog,
            timeLog: timeLog
        )
        let dominantColors = colorFrequencies.compactMap { NSColor(cgColor: $0.color) }
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
    public static func averageColors(
        nsImage: NSImage,
        count: Int = 8,
        sorting: Sort = .frequency
    ) throws -> [NSColor] {
        let cgImage = try cgImage(from: nsImage)
        let averageColors = try areaAverageColors(image: cgImage, count: UInt8(count), sorting: sorting)
            .compactMap { NSColor(cgColor: $0) }
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
    public static func kMeansClusteringColors(
        nsImage: NSImage,
        quality: DominantColorQuality = .fair,
        count: Int = 8,
        sorting: Sort = .frequency
    ) throws -> [NSColor] {
        let cgImage = try cgImage(from: nsImage)
        let kMeansClusteringColors = try kMeansClustering(image: cgImage, with: quality, count: count, sorting: sorting)
            .compactMap { NSColor(cgColor: $0) }
        return kMeansClusteringColors
    }
    
    private static func cgImage(from nsImage: NSImage) throws -> CGImage {
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { throw ImageColorError.cgImageFailure }
        return cgImage
    }
}

#endif
