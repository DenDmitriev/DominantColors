//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import CoreImage

extension CGImage {
    
    var resolution: CGSize {
        return CGSize(width: width, height: height)
    }
    
    func resize(to targetSize: CGSize) -> CGImage {
        guard targetSize != resolution else {
            return self
        }
        
        var ratio: Double = 0.0
        
        // Get ratio (landscape or portrait)
        if width > height {
            ratio = targetSize.width / CGFloat(width)
        } else {
            ratio = targetSize.height / CGFloat(height)
        }
        
        let ciImage = CIImage(cgImage: self)

        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(ratio, forKey: "inputScale")
        filter.setValue(1.0, forKey: "inputAspectRatio")
        guard let outputImage = filter.value(forKey: "outputImage") as? CIImage else { return self }

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let resizedImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
        
        return resizedImage
    }
    
}
