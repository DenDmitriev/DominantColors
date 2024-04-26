//
//  DominantColors.swift
//
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import CoreImage

public class DominantColors {
    /// Attempts to computes the dominant colors of the image.
    /// This is not the absolute dominent colors, but instead colors that are similar are groupped together.
    /// This avoids having to deal with many shades of the same colors, which are frequent when dealing with compression artifacts (jpeg etc.).
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    ///  - algorithm: The algorithm used to determine the dominant colors. When using a k-means algorithm (`kMeansClustering`), a `CIKMeans` CIFilter isused. Unfortunately this filter doesn't work on the simulator.
    ///  - maxCount: Max count colors from image.
    ///  - flags: Add options for extract colors.
    ///  - sorting: Type of sorting sequence colors.
    ///  - deltaColors: Only used for CIE76, CIE94, CIEDE2000, CMC algorithms. The score that needs to be met to consider two colors similar. The larger the value, the fewer shades will be obtained from the images
    ///     - 10 by default to match similar shades
    ///     - 2.3 approximately corresponds to the minimum difference between colors visible to the human eye.
    /// - Returns: The dominant colors as array of `CGColor` instances. When using the `.iterative` algorithm, this array is ordered where the first color is the most dominant one.
    public static func dominantColors(
        image: CGImage,
        with quality: DominantColorQuality = .fair,
        algorithm: DominantColorAlgorithm = .iterative(formula: .CIE76),
        dominationColors maxCount: Int = 8,
        flags: [Flag] = [],
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
                flags: flags,
                sorting: sorting,
                deltaColors: deltaColors,
                time: log
            )
            let dominantColors = dominantColorFrequencies.map { (colorFrequency) -> CGColor in
                return colorFrequency.color
            }
            
            return dominantColors
        case .kMeansClustering:
            let dominantColors = try kMeansClustering(
                image: image,
                with: quality,
                sorting: sorting
            )
            
            return dominantColors
            
        case .areaAverage(let count):
            let dominantColors = try areaAverageColors(
                image: image,
                count: count,
                sorting: sorting
            )
            return dominantColors
        }
    }
    
    public enum Flag {
        /// Remove pure black colors
        case excludeBlack
        /// Remove pure white colors
        case excludeWhite
        /// Resize image for speed
        case resize
    }
    
    public enum Sort: CaseIterable, Identifiable {
        /// Sorting colors from darkness to lightness.
        case darkness
        /// Sorting colors from lightness to darkness.
        case lightness
        /// Sorting colors by frequency in image.
        case frequency
        
        var name: String {
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
    
    /// Attempts to computes the dominant colors of the image.
    /// This is not the absolute dominent colors, but instead colors that are similar are groupped together.
    /// This avoid having to deal with many shades of the same colors, which are frequent when dealing with compression artifacts (jpeg etc.).
    /// - Parameters:
    ///   - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    /// - Returns: The dominant colors as an ordered array of `ColorFrequency` instances, where the first element is the most common one. The frequency is represented as a percentage ranging from 0 to 1.
    public static func dominantColorFrequencies(
        image: CGImage,
        with quality: DominantColorQuality = .fair,
        using formula: DeltaEFormula = .CIE76,
        dominationColors maxCount: Int = 99,
        flags: [Flag] = [],
        sorting: Sort = .frequency,
        deltaColors: CGFloat = 10,
        time log: Bool = false
    ) throws -> [ColorFrequency] {
        let startTime = CFAbsoluteTimeGetCurrent()
        var processTime = startTime
        // ------
        // Step 1: Resize the image based on the requested quality
        // ------
        var image = image
        print(image.width, image.height)
        if flags.contains(.resize) {
            image = resizeFilter(image: image, by: quality)
        }
        if log { Self.log(from: &processTime, label: "Step 1") }
        
        guard let filteredImage = pixellate(image: image, by: quality)
        else { throw ImageColorError.ciFilterCreateFailure(filter: "CIPixellate") }
        image = filteredImage
        print(image.width, image.height)
        
        guard let cfData = image.dataProvider!.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        // ------
        // Step 2: Add each pixel to a Dictionary. This will give us a count for each color.
        // ------
        
        let colorsOnImage: [RGB255: Int] = extractColors(image, data, isPixelate: true, quality: quality)
        if log { Self.log(from: &processTime, label: "Step 2") }
        print("colorsOnImage", colorsOnImage.count)
        // ------
        // Step 3: Remove colors that are barely present on the image.
        // ------
        
        // Минимальное количество пикселей для цвета
        let minCountThreshold = 1
        let filteredColors = filterColors(colorsOnImage, colorSpace: image.colorSpace, with: minCountThreshold)
        if log { Self.log(from: &processTime, label: "Step 3") }
        
        // ------
        // Step 4: Sort the remaning colors by frequency.
        // ------
        
        let sortedColors = filteredColors.sorted { (lhs, rhs) -> Bool in
            lhs.frequency > rhs.frequency
        }
        if log { Self.log(from: &processTime, label: "Step 4") }
        
        // ------
        // Step 5: Only keep the most frequent colors.
        // ------
        
        let maxNumberOfColors = 10000
        let sortedColorsSub = Array(sortedColors.prefix(maxNumberOfColors))
        if log { Self.log(from: &processTime, label: "Step 5") }
        
        // ------
        // Step 6: Combine similar colors together.
        // ------
        
        /// The main dominant colors on the picture.
        var dominantColors = combine(colorFrequencies: sortedColorsSub, with: formula, by: deltaColors)
        if log { Self.log(from: &processTime, label: "Step 6") }
        
        // ------
        // Step 6.1: Remove pure black colors
        // ------
        if flags.contains(.excludeBlack) {
            let blackMaxLightness: CGFloat = 10
            filterBlack(max: blackMaxLightness, colors: &dominantColors)
            filterBlack(delta: deltaColors, colors: &dominantColors, using: formula)
        }
        if log { Self.log(from: &processTime, label: "Step 6.1") }
        
        // ------
        // Step 6.2: Remove pure white colors
        // ------
        
        if flags.contains(.excludeWhite) {
            let whiteMinLightness: CGFloat = 90
            filterWhite(min: whiteMinLightness, colors: &dominantColors)
            filterBlack(delta: deltaColors, colors: &dominantColors, using: formula)
        }
        if log { Self.log(from: &processTime, label: "Step 6.2") }
        // ------
        // Step 6.3: Combine similar colors together again.
        // ------
        
//        dominantColors = clean(dominantColors: dominantColors, with: formula, by: deltaColors)
        if log { Self.log(from: &processTime, label: "Step 6.3") }
        
        
        // ------
        // Step 7: Again, limit the number of colors we keep, this time drastically.
        // ------
        
        // We only keep the first few dominant colors.
        dominantColors = Array(dominantColors.prefix(maxCount))
        if log { Self.log(from: &processTime, label: "Step 7") }
        
        // ------
        // Step 8: Sort again on frequencies because the order may have changed because we combined colors.
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
        if log { Self.log(from: &processTime, label: "Step 8") }
        
        // ------
        // Step 9: Calculate the frequency of colors as a percentage.
        // ------
        
        /// The total count of colors
        let dominantColorsTotalCount = dominantColors.reduce(into: 0) { (result, colorFrequency) in
            result += colorFrequency.frequency
        }
        
        dominantColors = dominantColors.enumerated().map({ (index, colorFrequency) -> ColorFrequency in
            let percentage = (100.0 / (dominantColorsTotalCount / colorFrequency.frequency) / 100.0).rounded(.up, precision: 100)
            
            return ColorFrequency(index: index, color: colorFrequency.color, count: percentage)
        })
        
        let extractTime = (CFAbsoluteTimeGetCurrent() - startTime).rounded(.toNearestOrAwayFromZero, precision: 1000)
        print("DominantColor extract colors count: \(dominantColors.count), time: \(extractTime)s")
        
        return dominantColors
    }
    
    private static func log(from time: inout CFAbsoluteTime, label: String) {
        let extractTime = (CFAbsoluteTimeGetCurrent() - time).rounded(.toNearestOrAwayFromZero, precision: 1000)
        print("\(label) time: \(extractTime)s")
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
    
    private static func clean(dominantColors: [ColorFrequency], with formula: DeltaEFormula, by delta: CGFloat = 10.0) -> [ColorFrequency] {
        var cleanedDominantColors = Set(dominantColors)
        var differenceScores = [ColorFrequency: [(color: ColorFrequency, difference: CGFloat)]]()
        let cleanDelta = delta * 3
        for dominantColor in dominantColors {
            for anotherDominantColor in dominantColors {
                guard dominantColor != anotherDominantColor else { continue }
                let differenceScore = dominantColor.color.difference(from: anotherDominantColor.color, using: formula).associatedValue
                if differenceScore < cleanDelta {
                    if differenceScores[dominantColor] == nil {
                        differenceScores[dominantColor] = []
                    }
                    differenceScores[dominantColor]?.append((anotherDominantColor, differenceScore))
                }
            }
        }
        
//        let similarColorsCountTrigger = 3
        var similarDominantColorsCombined = Set<ColorFrequency>()
        for differenceScore in differenceScores {
//            guard differenceScore.value.count >= similarColorsCountTrigger else { continue }
            var similarDominantColors = Set(differenceScore.value.map({ $0.color }))
            similarDominantColors.insert(differenceScore.key)
            cleanedDominantColors.subtract(similarDominantColors)
            let colorsCombined = combine(colorFrequencies: Array(similarDominantColors), with: formula, by: cleanDelta)
            similarDominantColorsCombined.formUnion(Set(colorsCombined))
//            print(similarDominantColors.count, "->", colorsCombined.count)
        }
        cleanedDominantColors.formUnion(Set(similarDominantColorsCombined))
        
        return cleanedDominantColors.sorted(by: { $0.frequency > $1.frequency })
    }
    
    /// Remove colors that are barely present on the image.
    ///
    /// - Parameters:
    ///  - minCount: Minimum count pixels for color
    private static func filterColors(_ colorsDictionary: [RGB255: Int], colorSpace: CGColorSpace?, with minCount: Int) -> Set<ColorFrequency> {
        var filteredColors = Set<ColorFrequency>()
        for (index, color) in colorsDictionary.enumerated() {
//            let count = colorsCountedSet.count(for: rgb)
            let count = color.value
            
            guard count >= minCount else { continue }
            
            let color = color.key
            
            let red = (CGFloat(color.red) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
            let green = (CGFloat(color.green) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
            let blue = (CGFloat(color.blue) / 255.0).rounded(.toNearestOrAwayFromZero, precision: 100)
            let alpha = 255.0
            
            let components: [CGFloat] = [red, green, blue, alpha]
            
            guard
                let colorSpace = colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
                let cgColor = CGColor(colorSpace: colorSpace, components: components)
            else { continue }
            
            
            let colorFrequency = ColorFrequency(index: index, color: cgColor, count: CGFloat(count))
            filteredColors.insert(colorFrequency)
        }
        
        return filteredColors
    }
    
    /// Extract colors pixel by pixel with countig
    private static func extractColors(_ image: CGImage, _ data: UnsafePointer<UInt8>, isPixelate: Bool = false, quality: DominantColorQuality? = nil) -> [RGB255: Int] {
        var colorsOnImage: [RGB255: Int] = [:]
        print(image.width, image.height)
        print("pixel count width:", image.width / quality!.pixellateScale.intValue)
        print("pixel count height:", image.height / quality!.pixellateScale.intValue)
        
        if isPixelate, let quality {
            let pixelSize = quality.pixellateScale.intValue
            
            for yCoordonate in 0..<(image.height/pixelSize) {
                for xCoordonate in 0..<(image.width/pixelSize) {
                    let index = (image.width * (yCoordonate * pixelSize) + (xCoordonate * pixelSize)) * 4
                    
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 3]
                    guard alpha > 150 else { continue }
                    
                    let red = data[index + 0]
                    let green = data[index + 1]
                    let blue = data[index + 2]
                    
                    let pixelColor = RGB255(red: red, green: green, blue: blue)
                    //                colorsCountedSet.add(pixelColor)
                    //                colorsOnImage.insert(pixelColor)
                    if colorsOnImage[pixelColor] != nil {
                        colorsOnImage[pixelColor]? += 1
                    } else {
                        colorsOnImage[pixelColor] = 1
                    }
                }
            }
        } else {
            for yCoordonate in 0 ..< image.height {
                for xCoordonate in 0 ..< image.width {
                    let index = (image.width * yCoordonate + xCoordonate) * 4
                    
                    // Let's make sure there is enough alpha 150 / 250 = 60%.
                    let alpha = data[index + 3]
                    guard alpha > 150 else {
                        print("is alpha")
                        continue
                    }
                    
                    let red = data[index + 0]
                    let green = data[index + 1]
                    let blue = data[index + 2]
                    
                    let pixelColor = RGB255(red: red, green: green, blue: blue)
                    //                colorsCountedSet.add(pixelColor)
                    //                colorsOnImage.insert(pixelColor)
                    if colorsOnImage[pixelColor] != nil {
                        colorsOnImage[pixelColor]? += 1
                    } else {
                        colorsOnImage[pixelColor] = 1
                    }
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
    static func filterBlack(max lightness: CGFloat = 5, colors: inout [ColorFrequency]) {
        colors.removeAll { color in
            color.color.hsl.lightness.rounded(.toNearestOrAwayFromZero) <= lightness
        }
    }
    
    /// White filter in colors
    ///
    /// Remove any colors that are above the minimum brightness.
    ///
    /// - parameters:
    /// - lightness: The maximum black brightness ranges from 0 to 100, where 0 is completely black and 100 is completely white.
    static func filterWhite(min lightness: CGFloat = 95, colors: inout [ColorFrequency]) {
        colors.removeAll { color in
            color.color.hsl.lightness.rounded(.toNearestOrAwayFromZero) >= lightness
        }
    }
    
    /// Black filter in colors
    ///
    /// Remove all colors whose difference in black is less than the color delta
    ///
    /// - parameters:
    /// - delta: Maximum black delta difference.
    static func filterBlack(delta: CGFloat, colors: inout [ColorFrequency], using formula: DeltaEFormula = .CIE76) {
        let black = CGColor.black
        colors.removeAll { color in
            let difference = black.difference(from: color.color, using: formula)
            guard !difference.associatedValue.isNaN else { return false }
            if difference.associatedValue < delta {
                return true
            } else {
                return false
            }
        }
    }
    
    /// White filter in colors
    ///
    /// Remove all colors whose difference in black is less than the color delta
    ///
    /// - parameters:
    /// - delta: Maximum white delta difference.
    static func filterWhite(delta: CGFloat, colors: inout [ColorFrequency], using formula: DeltaEFormula = .CIE76) {
        let white = CGColor.white
        colors.removeAll { color in
            let difference = white.difference(from: color.color, using: formula)
            guard !difference.associatedValue.isNaN else { return false }
            if difference.associatedValue < delta {
                return true
            } else {
                return false
            }
        }
    }
    
    /// Resize the image based on the requested quality
    private static func resizeFilter(image: CGImage, by quality: DominantColorQuality = .fair) -> CGImage {
        let targetSize = quality.targetSize(for: image.resolution)
        
        let resizedImage = image.resize(to: targetSize)
        
        return resizedImage
    }
    
    /// Makes an image blocky by mapping the image to colored squares whose color is defined by the replaced pixels..
    ///  https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPixellate
    private static func pixellate(image: CGImage, by quality: DominantColorQuality = .fair) -> CGImage? {
        guard let filter = CIFilter(name: "CIPixellate") else { return nil }
        
        let beginImage = CIImage(cgImage: image)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(quality.pixellateScale, forKey: kCIInputScaleKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()

        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent),
              let croppedCGImage = crop(image: outputCGImage, pixellateSize: quality.pixellateScale.intValue)
        else { return nil }
        
        print(#function, outputCGImage.height, outputCGImage.width)
        print(#function, croppedCGImage.height, croppedCGImage.width)
        return croppedCGImage
    }
    
    private static func crop(image: CGImage, pixellateSize: Int) -> CGImage? {
        let pixelSize = pixellateSize
        var rect = CGRectMake(0, 0, CGFloat(image.width), CGFloat(image.height))
        
        guard let cfData = image.dataProvider!.data,
              let data = CFDataGetBytePtr(cfData)
        else { return nil }
        
        outerLoop: for yCoordonate in 0 ..< image.height {
            for xCoordonate in 0 ..< image.width {
                let index = (image.width * yCoordonate + xCoordonate) * 4
                let alpha = data[index + 3]
                if alpha != 0 {
                    rect.origin.y = CGFloat(yCoordonate)
                    rect.origin.x = CGFloat(xCoordonate)
                    rect.size.width = CGFloat((image.width / pixelSize - 1) * pixelSize)
                    rect.size.height = CGFloat((image.height / pixelSize - 1) * pixelSize)
                    break outerLoop
                }
            }
        }
        print(#function, rect.minX, rect.maxX)
        
        guard let filter = CIFilter(name: "CICrop") else { return nil }
        
        let beginImage = CIImage(cgImage: image)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        let rectangle = CIVector(cgRect: rect)
        filter.setValue(rectangle, forKey: "inputRectangle")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()

        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return outputCGImage
    }
    
    private static func kMeansClustering(
        image: CGImage,
        with quality: DominantColorQuality,
        sorting: Sort = .frequency
    ) throws -> [CGColor] {
        let ciImage = CIImage(cgImage: image)
        let filter = "CIKMeans"
        guard let kMeansFilter = CIFilter(name: filter) else {
            throw ImageColorError.ciFilterCreateFailure(filter: filter)
        }
        
        let clusterCount = 8

        kMeansFilter.setValue(ciImage, forKey: kCIInputImageKey)
        kMeansFilter.setValue(CIVector(cgRect: ciImage.extent), forKey: "inputExtent")
        kMeansFilter.setValue(clusterCount, forKey: "inputCount")
        kMeansFilter.setValue(quality.kMeansInputPasses, forKey: "inputPasses")
        kMeansFilter.setValue(NSNumber(value: true), forKey: "inputPerceptual")

        guard var outputImage = kMeansFilter.outputImage else {
            throw ImageColorError.outputImageFailure
        }
        
        outputImage = outputImage.settingAlphaOne(in: outputImage.extent)
        
        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4 * clusterCount)
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4 * clusterCount, bounds: outputImage.extent, format: CIFormat.RGBA8, colorSpace: ciImage.colorSpace!)
        
        var dominantColors = [CGColor]()

        for i in 0..<clusterCount {
            let red: CGFloat = CGFloat(bitmap[i * 4 + 0]) / 255.0
            let green: CGFloat = CGFloat(bitmap[i * 4 + 1]) / 255.0
            let blue: CGFloat = CGFloat(bitmap[i * 4 + 2]) / 255.0
            let alpha: CGFloat = CGFloat(bitmap[i * 4 + 3]) / 255.0
            
            let components: [CGFloat] = [red, green, blue, alpha]
            
            guard
                let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
                let color = CGColor(colorSpace: colorSpace, components: components)
            else { throw ImageColorError.cgColorFailure }
            
            dominantColors.append(color)
        }
        
        switch sorting {
        case .darkness:
            dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.lightness < rhs.lightness
            })
        case .lightness:
            dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.lightness > rhs.lightness
            })
        case .frequency:
            break
        }
        
        return dominantColors
    }
    
    
    private static func areaAverageColors(
        image: CGImage,
        count: UInt8,
        sorting: Sort = .frequency
    ) throws -> [CGColor] {
        let ciImage = CIImage(cgImage: image)
        guard
            1...image.width ~= Int(count),
            count != .zero
        else {
            throw ImageColorError.lowResolutionFailure
        }
        let extentVectors = [Int] (0...(Int(count)-1)).map { part in
            let partWidth = ciImage.extent.size.width / CGFloat(count)
            let extentVector = CIVector(
                x: partWidth * CGFloat(part),
                y: ciImage.extent.origin.y,
                z: partWidth,
                w: ciImage.extent.size.height
            )
            return extentVector
        }
        
        let filters = extentVectors.compactMap {
            let filter = CIFilter(
                name: "CIAreaAverage",
                parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: $0]
            )
            return filter
        }
        let outputImages = filters.compactMap { $0.outputImage }
        
        var bitmaps: [[UInt8]] = []
        
        guard let kCFNull = kCFNull else {
            throw ImageColorError.kCFNullFailure
        }
        
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        outputImages.forEach { outputImage in
            var bitmap = [UInt8](repeating: 0, count: 4)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
            bitmaps.append(bitmap)
        }
        
        var averageColors = bitmaps.compactMap { bitmap -> CGColor? in
            let red = CGFloat(bitmap[0]) / 255.0
            let green = CGFloat(bitmap[1]) / 255.0
            let blue = CGFloat(bitmap[2]) / 255.0
            let alpha = CGFloat(bitmap[3]) / 255.0
            
            let components: [CGFloat] = [red, green, blue, alpha]
            guard
                let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
                let cgColor = CGColor(colorSpace: colorSpace, components: components)
            else { return nil }
            
            return cgColor
        }
        
        switch sorting {
        case .darkness:
            averageColors = averageColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.lightness < rhs.lightness
            })
        case .lightness:
            averageColors = averageColors.sorted(by: { (lhs, rhs) -> Bool in
                lhs.lightness > rhs.lightness
            })
        case .frequency:
            break
        }
        
        return averageColors
    }
}

