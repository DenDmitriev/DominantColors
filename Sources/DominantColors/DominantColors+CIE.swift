//
//  DominantColors+CIE.swift
//
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import Foundation
import CoreGraphics.CGImage

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
    /// - Returns: The dominant colors as array of `CGColor` instances.
    public static func dominantColors(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        algorithm: DeltaEFormula = .CIE94,
        maxCount: Int = 8,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        resultLog: Bool = false,
        timeLog: Bool = false
    ) throws -> [CGColor] {
        let dominantColorFrequencies = try dominantColorFrequencies(
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
        let dominantColors = dominantColorFrequencies.map { $0.color }
        return dominantColors
    }
    
    /// Attempts to computes the dominant colors of the image.
    /// This is not the absolute dominant colors, but instead colors that are similar are grouped together.
    /// This avoid having to deal with many shades of the same colors, which are frequent when dealing with compression artifacts (jpeg etc.).
    /// - Parameters:
    ///   - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    /// - Returns: The dominant colors as an ordered array of `ColorFrequency` instances, where the first element is the most common one. The frequency is represented as a percentage ranging from 0 to 1.
    static func dominantColorFrequencies(
        image: CGImage,
        quality: DominantColorQuality = .fair,
        formula: DeltaEFormula = .CIE76,
        maxCount: Int = 99,
        options: [Options] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        resultLog: Bool = false,
        timeLog: Bool = false
    ) throws -> [ColorFrequency] {
        let startTime = CFAbsoluteTimeGetCurrent()
        var processTime = startTime
        // ------
        // Step 1: Resize, Pixellate, Crop the image based on the requested quality
        // ------
        var image = image
        switch quality {
        case .low:
            image = ImageFilter.resizeFilter(image: image, by: quality)
            image = try ImageFilter.pixellate(image: image, by: .best)
            image = try ImageFilter.cropAlpha(image: image)
        case .fair:
            image = ImageFilter.resizeFilter(image: image, by: quality)
            image = try ImageFilter.pixellate(image: image, by: .best)
            image = try ImageFilter.cropAlpha(image: image)
        case .high:
            image = ImageFilter.resizeFilter(image: image, by: quality)
            image = try ImageFilter.pixellate(image: image, by: .best)
            image = try ImageFilter.cropAlpha(image: image)
        case .best:
            break
        }
        if timeLog { Self.log(from: &processTime, label: "Step 1. Prepare image.") }
                
        // ------
        // Step 2: Add each pixel to a NSCountedSet. This will give us a count for each color.
        // ------
        let colorsCountedSet: NSCountedSet
        switch quality {
        case .low:
            let pixelSize = DominantColorQuality.best.pixellateScale.intValue
            colorsCountedSet = try extractColors(pixellate: image, pixelSize: pixelSize)
        case .fair:
            let pixelSize = DominantColorQuality.best.pixellateScale.intValue
            colorsCountedSet = try extractColors(pixellate: image, pixelSize: pixelSize)
        case .high:
            let pixelSize = DominantColorQuality.best.pixellateScale.intValue
            colorsCountedSet = try extractColors(pixellate: image, pixelSize: pixelSize)
        case .best:
            colorsCountedSet = try extractColors(image)
        }
        if timeLog { Self.log(from: &processTime, label: "Step 2. Get colors from pixels.") }
        
        // ------
        // Step 3: Filtering pixel colors into shades. Remove colors that are barely present on the image.
        // ------
        
        let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let minCountThreshold: Int // Minimum number of pixels for color
        switch quality {
        case .low, .fair, .high:
            minCountThreshold = 1
        case .best:
            minCountThreshold = 4
        }
        let colorShades = filterColorsByShade(colorsCountedSet, colorSpace: colorSpace, minCount: minCountThreshold, flags: options)
        if timeLog { Self.log(from: &processTime, label: "Step 3. Filter colors by shade.") }
        
        // ------
        // Step 4: Sort the remaining colors by frequency and normality. Leave only the most normal and frequently occurring colors.
        // ------
        let sortedColors = colorShades.mapValues { colorFrequenciesSet in
            switch quality {
            case .low, .fair, .high:
                return colorFrequenciesSet
                    .sorted(by: { $0.normal > $1.normal })
            case .best:
                let maxNumberOfColors = 100
                let colorFrequenciesArray = colorFrequenciesSet
                    .sorted(by: { $0.normal > $1.normal })
                    .prefix(maxNumberOfColors)
                return Array(colorFrequenciesArray)
            }
        }
        if timeLog { Self.log(from: &processTime, label: "Step 4. Sorting by normal.") }
        
        // ------
        // Step 5: Combine similar colors for each shade together.
        // ------
        let dominantColorsByShade = sortedColors.mapValues { colorFrequencies in
            var dominantColors = combine(colorFrequencies: colorFrequencies, with: formula, by: deltaColors)
                .sorted(by: { $0.normal > $1.normal })
            var deltaColorsIncrement = deltaColors
            // We increase the difference to combine colors until there are less than max count shades left in each shade.
            while dominantColors.count > maxCount {
                deltaColorsIncrement += 1
                dominantColors = combine(colorFrequencies: dominantColors, with: formula, by: deltaColorsIncrement)
                    .sorted(by: { $0.normal > $1.normal })
            }
            return dominantColors
        }
        if timeLog { Self.log(from: &processTime, label: "Step 5. Combine similar colors by shade.") }
        
        // ------
        // Step 6: Let's combine the colors from all the shades together and combine them with each other for now.
        //         We will combine until we get the requested number of colors.
        // ------
        
        var dominantColors = dominantColorsByShade.values.flatMap({ $0 })
            .sorted(by: { $0.normal > $1.normal })
        var deltaColorsIncrement = deltaColors
        while dominantColors.count > maxCount {
            dominantColors = combine(colorFrequencies: dominantColors, with: formula, by: deltaColorsIncrement)
                .sorted(by: { $0.normal > $1.normal })
            deltaColorsIncrement += 1
        }
        if timeLog { Self.log(from: &processTime, label: "Step 6. Combine similar colors.") }
        
        // ------
        // Step 6.1: Add color if the combination results in few colors.
        // ------
        if dominantColors.count < maxCount {
            let countForAdd = maxCount - dominantColors.count
            let additionalColors = getAdditionalColors(count: countForAdd, current: dominantColors, from: dominantColorsByShade, formula: formula, deltaColors: deltaColors)
            dominantColors.append(contentsOf: additionalColors)
        }
        if timeLog { Self.log(from: &processTime, label: "Step 6.1. Add colors if count less.") }
        
        // ------
        // Step 7: Let's sort the colors by the requested type.
        // ------
        
        switch sorting {
        case .darkness:
            dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.color.relativeLuminance < rhs.color.relativeLuminance
            })
        case .lightness:
            dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.color.relativeLuminance > rhs.color.relativeLuminance
            })
        case .frequency:
            dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.frequency > rhs.frequency
            })
        }
        if timeLog { Self.log(from: &processTime, label: "Step 7. Final sorting.") }
        
        // ------
        // Step 8: Calculate the frequency of colors as a percentage.
        // ------
        
        /// The total count of colors
        let dominantColorsTotalCount = dominantColors.reduce(into: 0) { (result, colorFrequency) in
            result += colorFrequency.frequency
        }
        
        dominantColors = dominantColors.enumerated().map({ (index, colorFrequency) -> ColorFrequency in
            let percentage = (100.0 / (dominantColorsTotalCount / colorFrequency.frequency) / 100.0).rounded(.up, precision: 100)
            
            return ColorFrequency(color: colorFrequency.color, count: percentage)
        })
        if timeLog { Self.log(from: &processTime, label: "Step 8. Calculate the frequency of colors as a percentage.") }
        
        // ------
        // Final: Calculate the frequency of colors as a percentage.
        // ------
        let extractTime = (CFAbsoluteTimeGetCurrent() - startTime).rounded(.toNearestOrAwayFromZero, precision: 1000)
        if resultLog {
            print("DominantColor extract colors: \(dominantColors.map({ $0.shade })), count: \(dominantColors.count), time: \(extractTime)s")
        }
        
        return dominantColors
    }
    
    private static func log(from time: inout CFAbsoluteTime, label: String) {
        let extractTime = (CFAbsoluteTimeGetCurrent() - time).rounded(.toNearestOrAwayFromZero, precision: 1000)
        print("\(label) ⏱️: \(extractTime)s")
        time = CFAbsoluteTimeGetCurrent()
    }
    
    /// Combines colors that are similar
    ///
    /// - Parameters:
    ///   - colors: Colors type class `ColorFrequency` by pixel in image.
    ///   - formula: The different algorithms for comparing colors.
    ///   - delta: The score that needs to be met to consider two colors similar.
    ///
    /// - Returns: The main dominant colors on the picture.
    private static func combine(colorFrequencies: [ColorFrequency], with formula: DeltaEFormula, by delta: CGFloat = 10.0) -> [ColorFrequency] {
        /// The main dominant colors on the picture.
        var dominantColors = Set<ColorFrequency>()
        
        /// The score that needs to be met to consider two colors similar.
        let colorDifferenceScoreThreshold = delta
        
        // Combines colors that are similar.
        for colorFrequency in colorFrequencies {
            var bestMatchScore: CGFloat?
            var bestMatchColorFrequency: ColorFrequency?
            
            // Проход по уже добавленным цветам на лучшее соответсвие
            for dominantColor in dominantColors {
                let differenceScore = colorFrequency.color.difference(from: dominantColor.color, using: formula).associatedValue
                if differenceScore < bestMatchScore ?? CGFloat(Int.max) {
                    bestMatchScore = differenceScore
                    bestMatchColorFrequency = dominantColor
                }
            }
            
            if let bestMatchScore = bestMatchScore, bestMatchScore < colorDifferenceScoreThreshold {
                // Если соответсвие с другими цветами найдено, то увеличиваем счетчик пикселей этого цвета
                bestMatchColorFrequency!.frequency += 1
            } else {
                // Если соответсвие с другими цветами не найдены, то это новый доминирующий цвет
                dominantColors.insert(colorFrequency)
            }
        }
        
        return dominantColors.sorted(by: { $0.frequency > $1.frequency })
    }
    
    /// Remove colors that are barely present on the image.
    ///
    /// - Parameters:
    ///  - minCount: Minimum count pixels for color
    static func filterColors(_ colorsCountedSet: NSCountedSet, colorSpace: CGColorSpace, minCount: Int = 1) -> Set<ColorFrequency> {
        var filteredColors = Set<ColorFrequency>()
        
        for color in colorsCountedSet {
            let count = colorsCountedSet.count(for: color)
            guard count >= minCount,
                  let color = color as? RGB255
            else { continue }
            
            let cgColor = color.cgColor(colorSpace: colorSpace)
            
            let colorFrequency = ColorFrequency(color: cgColor, count: CGFloat(count))
            filteredColors.insert(colorFrequency)
        }
        
        return filteredColors
    }
    
    /// Filter colors by shades on the image.
    ///
    /// - Parameters:
    ///  - minCount: Minimum count pixels for color
    static func filterColorsByShade(_ colorsCountedSet: NSCountedSet, colorSpace: CGColorSpace, minCount: Int = 1, flags: [DominantColors.Options]) -> [ColorShade: Set<ColorFrequency>] {
        var filteredColors = [ColorShade: Set<ColorFrequency>]()
        ColorShade.allCases.forEach { shade in
            filteredColors[shade] = Set<ColorFrequency>()
        }
        
        for color in colorsCountedSet {
            let count = colorsCountedSet.count(for: color)
            guard count >= minCount,
                  let color = color as? RGB255
            else { continue }
            
            let cgColor = color.cgColor(colorSpace: colorSpace)
            let colorFrequency = ColorFrequency(color: cgColor, count: CGFloat(count))
            
            if flags.contains(.excludeBlack) {
                if colorFrequency.shade == .black { continue }
            }
            
            if flags.contains(.excludeWhite) {
                if colorFrequency.shade == .white { continue }
            }
            
            if flags.contains(.excludeGray) {
                if colorFrequency.shade == .gray { continue }
            }
            
            filteredColors[colorFrequency.shade]?.insert(colorFrequency)
        }
        
        return filteredColors
    }
    
    /// Extract colors pixel by pixel with counting
    static func extractColors(_ image: CGImage) throws -> NSCountedSet {
        guard let cfData = image.dataProvider?.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        var channels = 4
        if grayColorSpaces.contains(image.colorSpace) {
            channels = 2 // gray and alpha
        }
        
        let colorsOnImage = NSCountedSet(capacity: Int(image.resolution.area))
        for yCoordonate in 0 ..< image.height {
            for xCoordonate in 0 ..< image.width {
                let index = (image.width * yCoordonate + xCoordonate) * channels
                var pixelColor: RGB255?
                if channels == 4 {
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 3]
                    guard alpha > 150 else {
                        continue
                    }
                    
                    let red = data[index + 0]
                    let green = data[index + 1]
                    let blue = data[index + 2]
                    pixelColor = RGB255(red: red, green: green, blue: blue)
                } else if channels == 2 {
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 1]
                    guard alpha > 150 else {
                        continue
                    }
                    let gray = data[index]
                    pixelColor = RGB255(red: gray, green: gray, blue: gray)
                }
                if let pixelColor {
                    colorsOnImage.add(pixelColor)
                }
            }
        }
        
        return colorsOnImage
    }
    
    /// Extract colors from pixellate image with countig
    static func extractColors(pixellate image: CGImage, pixelSize: Int) throws -> NSCountedSet {
        guard let cfData = image.dataProvider?.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        var channels = 4
        if grayColorSpaces.contains(image.colorSpace) {
            channels = 2 // gray and alpha
        }
        
        let colorsOnImage = NSCountedSet(capacity: Int(image.resolution.area))
        for yCoordonate in 0 ..< image.height / pixelSize {
            for xCoordonate in 0 ..< image.width / pixelSize {
                let inset = pixelSize / 2
                let index = (image.width * yCoordonate + xCoordonate + inset) * pixelSize * channels
                var pixelColor: RGB255?
                if channels == 4 {
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 3]
                    guard alpha > 150 else {
                        continue
                    }
                    
                    let red = data[index + 0]
                    let green = data[index + 1]
                    let blue = data[index + 2]
                    pixelColor = RGB255(red: red, green: green, blue: blue)
                } else if channels == 2 {
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 1]
                    guard alpha > 150 else {
                        continue
                    }
                    let gray = data[index]
                    pixelColor = RGB255(red: gray, green: gray, blue: gray)
                }
                
                if let pixelColor {
                    colorsOnImage.add(pixelColor)
                }
            }
        }
        
        return colorsOnImage
    }
    
    /// Black filter in colors
    ///
    /// Remove all color less than maximum lightness
    ///
    /// - parameters:
    /// - lightness: The maximum black brightness ranges from 0 to 100, where 0 is completely black and 100 is completely white.
    @discardableResult
    static func removeBlack(max lightness: CGFloat = 5, colors: inout [ColorFrequency]) -> [ColorFrequency] {
        var removedColors = [ColorFrequency]()
        colors.removeAll { color in
            let isBlack = color.color.hsl.lightness.rounded(.toNearestOrAwayFromZero) <= lightness
            if isBlack { removedColors.append(color) }
            return isBlack
        }
        return removedColors
    }
    
    /// White filter in colors
    ///
    /// Remove any colors that are above the minimum brightness.
    ///
    /// - parameters:
    /// - lightness: The maximum black brightness ranges from 0 to 100, where 0 is completely black and 100 is completely white.
    @discardableResult
    static func removeWhite(min lightness: CGFloat = 95, colors: inout [ColorFrequency]) -> [ColorFrequency] {
        var removedColors = [ColorFrequency]()
        colors.removeAll { color in
            let isWhite = color.color.hsl.lightness.rounded(.toNearestOrAwayFromZero) >= lightness
            if isWhite { removedColors.append(color) }
            return isWhite
        }
        return removedColors
    }
    
    /// Black filter in colors
    ///
    /// Remove all colors whose difference in black is less than the color delta
    ///
    /// - parameters:
    /// - delta: Maximum black delta difference.
    @discardableResult
    static func removeBlack(delta: CGFloat, colors: inout [ColorFrequency], using formula: DeltaEFormula = .CIE76) -> [ColorFrequency] {
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        var removedColors = [ColorFrequency]()
        colors.removeAll { color in
            let difference = black.difference(from: color.color, using: formula)
            guard !difference.associatedValue.isNaN else { return false }
            if difference.associatedValue < delta {
                removedColors.append(color)
                return true
            } else {
                return false
            }
        }
        return removedColors
    }
    
    /// White filter in colors
    ///
    /// Remove all colors whose difference in black is less than the color delta
    ///
    /// - parameters:
    /// - delta: Maximum white delta difference.
    @discardableResult
    static func removeWhite(delta: CGFloat, colors: inout [ColorFrequency], using formula: DeltaEFormula = .CIE76) -> [ColorFrequency] {
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0)
        var removedColors = [ColorFrequency]()
        colors.removeAll { color in
            let difference = white.difference(from: color.color, using: formula)
            guard !difference.associatedValue.isNaN else { return false }
            if difference.associatedValue < delta {
                removedColors.append(color)
                return true
            } else {
                return false
            }
        }
        return removedColors
    }
    
    /// Adds missing colors from those not included in the selection
    static func getAdditionalColors(count: Int, current dominantColors: [ColorFrequency], from dominantColorsByShade: [ColorShade: [ColorFrequency]], formula: DeltaEFormula, deltaColors: CGFloat) -> [ColorFrequency] {
        var result = [ColorFrequency]()
        
        let sortedColorShades = Array(dominantColorsByShade.keys).sorted()
        colorShadeLoop: for colorShade in sortedColorShades {
            guard let dominantColorsOfShade = dominantColorsByShade[colorShade] else { continue }
            for colorFrequency in dominantColorsOfShade.sorted(by: { $0.normal > $1.normal }) {
                guard !dominantColors.contains(colorFrequency),
                      !result.contains(colorFrequency)
                else { continue }
                result.append(colorFrequency)
                if result.count >= count { break colorShadeLoop }
            }
        }
        
        return result
    }
    
    private static var grayColorSpaces: [CGColorSpace?] = [
        CGColorSpace(name: CGColorSpace.genericGrayGamma2_2),
        CGColorSpace(name: CGColorSpace.linearGray),
        CGColorSpace(name: CGColorSpace.extendedGray),
        CGColorSpace(name: CGColorSpace.extendedLinearGray),
    ]
}
