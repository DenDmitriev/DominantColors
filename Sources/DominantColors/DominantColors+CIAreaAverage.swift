//
//  DominantColors+CIAreaAverage.swift
//
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import Foundation
import CoreImage

extension DominantColors {
    /// Extract the dominant colors of the image.
    ///
    /// Finds the dominant colors of an image by using using a area average algorithm with CIAreaAverage filter.
    /// - Parameters:
    ///  - image: Source image for extract colors.
    ///  - count: Number of colors for the image.
    ///  - sorting: Type of sorting sequence colors.
    /// - Returns: Average colors, specified as an array of `CGColor` instances.
    public static func averageColors(
        image: CGImage,
        count: Int = 8,
        sorting: Sort = .frequency
    ) throws -> [CGColor] {
        let averageColors = try areaAverageColors(image: image, count: UInt8(count), sorting: sorting)
        return averageColors
    }
    
    static func areaAverageColors(
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
