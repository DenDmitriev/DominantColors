//
//  DominantColors+CIKMeans.swift
//
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import Foundation
import CoreImage

extension DominantColors {
    static func kMeansClustering(
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
}
