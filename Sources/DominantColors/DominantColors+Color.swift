//
//  DominantColors+Color.swift
//
//
//  Created by Jonathan Rajya on 18.10.2026.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension DominantColors {
    
    /// Extract the dominant colors of the image.
    ///
    /// Same as ``dominantColors(image:quality:algorithm:maxCount:options:sorting:deltaColors:resultLog:timeLog:)``,
    /// but returns SwiftUI `Color` values that can be used in a view directly.
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    ///  - algorithm: The different algorithms for comparing colors.
    ///  - maxCount: Maximum number of colors for the image.
    ///  - options: Some of additional options for removing flowers.
    ///  - sorting: Type of sorting sequence colors.
    ///  - deltaColors: The score that needs to be met to consider two colors similar. The larger the value, the fewer shades will be obtained from the images.
    ///  - resultLog: Logs a transcript of the results with the total time and number of colors for debug.
    ///  - timeLog: Logs each step of the algorithm with time for debug.
    /// - Returns: The dominant colors as array of `Color` instances.
    public static func dominantSwiftUIColors(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        algorithm: DeltaEFormula = .CIE94,
        maxCount: Int = 8,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        resultLog: Bool = false,
        timeLog: Bool = false
    ) throws -> [Color] {
        try dominantColors(
            image: image,
            quality: quality,
            algorithm: algorithm,
            maxCount: maxCount,
            options: options,
            sorting: sorting,
            deltaColors: deltaColors,
            resultLog: resultLog,
            timeLog: timeLog
        )
        .map { Color(cgColor: $0) }
    }
}
