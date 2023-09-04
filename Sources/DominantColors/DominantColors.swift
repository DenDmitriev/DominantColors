//
//  File.swift
//
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import CoreImage

/// A simple structure containing a color, and a frequency.
public class ColorFrequency: CustomStringConvertible {
    
    /// A simple `CGColor` instance.
    public let color: CGColor
    
    /// The frequency of the color.
    /// That is, how much it is present.
    public var frequency: CGFloat
    
    public var description: String {
        return "Color: \(color) - Frequency: \(frequency)"
    }
    
    init(color: CGColor, count: CGFloat) {
        self.frequency = count
        self.color = color
    }
}

public class DominantColors {
    
    /// Attempts to computes the dominant colors of the image.
    /// This is not the absolute dominent colors, but instead colors that are similar are groupped together.
    /// This avoids having to deal with many shades of the same colors, which are frequent when dealing with compression artifacts (jpeg etc.).
    /// - Parameters:
    ///   - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    ///   - algorithm: The algorithm used to determine the dominant colors. When using a k-means algorithm (`kMeansClustering`), a `CIKMeans` CIFilter isused. Unfortunately this filter doesn't work on the simulator.
    /// - Returns: The dominant colors as array of `CGColor` instances. When using the `.iterative` algorithm, this array is ordered where the first color is the most dominant one.
    public static func dominantColors(image: CGImage, with quality: DominantColorQuality = .fair, algorithm: DominantColorAlgorithm = .iterative) throws -> [CGColor] {
        switch algorithm {
        case .iterative:
            let dominantColorFrequencies = try dominantColorFrequencies(image: image, with: quality)
            let dominantColors = dominantColorFrequencies.map { (colorFrequency) -> CGColor in
                return colorFrequency.color
            }
            
            return dominantColors
        case .kMeansClustering:
            let dominantColors = try kMeansClustering(image: image, with: quality)
            return dominantColors
            
        case .areaAverage(let count):
            let dominantColors = try areaAverageColors(image: image, count: count)
            return dominantColors
        }
    }
    
    /// Attempts to computes the dominant colors of the image.
    /// This is not the absolute dominent colors, but instead colors that are similar are groupped together.
    /// This avoid having to deal with many shades of the same colors, which are frequent when dealing with compression artifacts (jpeg etc.).
    /// - Parameters:
    ///   - quality: The quality used to determine the dominant colors. A higher quality will yield more accurate results, but will be slower.
    /// - Returns: The dominant colors as an ordered array of `ColorFrequency` instances, where the first element is the most common one. The frequency is represented as a percentage ranging from 0 to 1.
    public static func dominantColorFrequencies(image: CGImage, with quality: DominantColorQuality = .fair) throws -> [ColorFrequency] {
        
        // ------
        // Step 1: Resize the image based on the requested quality
        // ------
        
        let targetSize = quality.targetSize(for: image.resolution)
        
        let resizedImage = image.resize(to: targetSize)
        let cgImage = resizedImage
        
        let cfData = cgImage.dataProvider!.data
        guard let data = CFDataGetBytePtr(cfData) else {
            throw ImageColorError.cgImageDataFailure
        }
        
        // ------
        // Step 2: Add each pixel to a NSCountedSet. This will give us a count for each color.
        // ------
        
        let colorsCountedSet = NSCountedSet(capacity: Int(targetSize.area))
        
        struct RGB: Hashable {
            let R: UInt8
            let G: UInt8
            let B: UInt8
        }

        for yCoordonate in 0 ..< cgImage.height {
            for xCoordonate in 0 ..< cgImage.width {
                let index = (cgImage.width * yCoordonate + xCoordonate) * 4
                
                // Let's make sure there is enough alpha.
                guard data[index + 3] > 150 else { continue }
                
                let pixelColor = RGB(R: data[index + 0], G: data[index + 1], B:  data[index + 2])
                colorsCountedSet.add(pixelColor)
            }
        }
        
        // ------
        // Step 3: Remove colors that are barely present on the image.
        // ------
        
        let areaPart = 0.01 / 100.0
        let minCountThreshold = Int(targetSize.area * areaPart)
        
        let filteredColorsCountMap = colorsCountedSet.compactMap { (rgb) -> ColorFrequency? in
            let count = colorsCountedSet.count(for: rgb)
            
            guard count > minCountThreshold else {
                return nil
            }
            
            let rgb = rgb as! RGB

            return ColorFrequency(color: CGColor(red: CGFloat(rgb.R) / 255.0, green: CGFloat(rgb.G) / 255.0, blue: CGFloat(rgb.B) / 255.0, alpha: 1.0), count: CGFloat(count))
        }
        
        // ------
        // Step 4: Sort the remaning colors by frequency.
        // ------
        
        let sortedColorsFrequencies = filteredColorsCountMap.sorted { (lhs, rhs) -> Bool in
            return lhs.frequency > rhs.frequency
        }
        
        // ------
        // Step 5: Only keep the most frequent colors.
        // ------
        
        let maxNumberOfColors = 500
        let colorFrequencies = sortedColorsFrequencies.prefix(maxNumberOfColors)
        
        // ------
        // Step 6: Combine similar colors together.
        // ------
        
        /// The main dominant colors on the picture.
        var dominantColors = [ColorFrequency]()
        
        /// The score that needs to be met to consider two colors similar.
        let colorDifferenceScoreThreshold: CGFloat = 20.0
        
        // Combines colors that are similar.
        for colorFrequency in colorFrequencies {
            var bestMatchScore: CGFloat?
            var bestMatchColorFrequency: ColorFrequency?
            for dominantColor in dominantColors {
                let differenceScore = colorFrequency.color.difference(from: dominantColor.color, using: .CIE76).associatedValue
                if differenceScore < bestMatchScore ?? CGFloat(Int.max) {
                    bestMatchScore = differenceScore
                    bestMatchColorFrequency = dominantColor
                }
            }
            
            if let bestMatchScore = bestMatchScore, bestMatchScore < colorDifferenceScoreThreshold {
                bestMatchColorFrequency!.frequency += 1
            } else {
                dominantColors.append(colorFrequency)
            }
        }
        
        // ------
        // Step 7: Again, limit the number of colors we keep, this time drastically.
        // ------
        
        // We only keep the first few dominant colors.
        let dominantColorsMaxCount = 8
        dominantColors = Array(dominantColors.prefix(dominantColorsMaxCount))
        
        // ------
        // Step 8: Sort again on frequencies because the order may have changed because we combined colors.
        // ------
        
        dominantColors = dominantColors.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.frequency > rhs.frequency
        })
        
        // ------
        // Step 9: Calculate the frequency of colors as a percentage.
        // ------
        
        /// The total count of colors
        let dominantColorsTotalCount = dominantColors.reduce(into: 0) { (result, colorFrequency) in
            result += colorFrequency.frequency
        }
        
        dominantColors = dominantColors.map({ (colorFrequency) -> ColorFrequency in
            let percentage = (100.0 / (dominantColorsTotalCount / colorFrequency.frequency) / 100.0).rounded(.up, precision: 100)
            
            return ColorFrequency(color: colorFrequency.color, count: percentage)
        })
        
        return dominantColors
    }
    
    private static func kMeansClustering(image: CGImage, with quality: DominantColorQuality) throws -> [CGColor] {
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
            let color = CGColor(red: CGFloat(bitmap[i * 4 + 0]) / 255.0, green: CGFloat(bitmap[i * 4 + 1]) / 255.0, blue: CGFloat(bitmap[i * 4 + 2]) / 255.0, alpha: CGFloat(bitmap[i * 4 + 3]) / 255.0)
            dominantColors.append(color)
        }
        
        return dominantColors
    }
    
    
    private static func areaAverageColors(image: CGImage, count: UInt8) throws -> [CGColor] {
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
        
        let averageColors = bitmaps.map { bitmap in
            let red = CGFloat(bitmap[0]) / 255.0
            let green = CGFloat(bitmap[1]) / 255.0
            let blue = CGFloat(bitmap[2]) / 255.0
            let alpha = CGFloat(bitmap[3]) / 255.0
            return CGColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return averageColors
    }
    
}

