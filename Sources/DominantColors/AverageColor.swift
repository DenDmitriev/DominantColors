//
//  AverageColor.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

public class AverageColor {
    
    /// Computes the average color of the image.
    static func averageColor(image: CGImage) throws -> CGColor {
        let ciImage = CIImage(cgImage: image)
        
        guard let areaAverageFilter = CIFilter(name: "CIAreaAverage") else {
            fatalError("Could not create `CIAreaAverage` filter.")
        }
        
        areaAverageFilter.setValue(ciImage, forKey: kCIInputImageKey)
        areaAverageFilter.setValue(CIVector(cgRect: ciImage.extent), forKey: "inputExtent")
        
        guard let outputImage = areaAverageFilter.outputImage else {
            throw ImageColorError.outputImageFailure
        }

        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        let averageColor = CGColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        
        return averageColor
    }
}
