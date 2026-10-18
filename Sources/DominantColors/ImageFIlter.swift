//
//  ImageFilter.swift
//
//
//  Created by Denis Dmitriev on 28.04.2024.
//

import CoreImage

class ImageFilter {

    /// One context for every filter pass. Creating a `CIContext` is expensive and each new one recompiles its kernels.
    static let ciContext = CIContext()

    /// Resize the image based on the requested quality
    static func resizeFilter(image: CGImage, by quality: DominantColorQuality = .fair) -> CGImage {
        let targetSize = quality.targetSize(for: image.resolution)
        
        let resizedImage = image.resize(to: targetSize)
        
        return resizedImage
    }
    
    /// Makes an image blocky by mapping the image to colored squares whose color is defined by the replaced pixels..
    /// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPixellate
    static func pixellate(image: CGImage, by quality: DominantColorQuality = .fair) throws -> CGImage {
        let filterName = "CIPixellate"
        guard let filter = CIFilter(name: filterName)
        else { throw ImageColorError.ciFilterCreateFailure(filter: filterName) }
        
        let beginImage = CIImage(cgImage: image)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(quality.pixellateScale, forKey: kCIInputScaleKey)
        
        guard let outputImage = filter.outputImage
        else { throw ImageColorError.ciFilterCreateFailure(filter: filterName) }
        
        let context = ciContext
        
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { throw ImageColorError.ciFilterCreateFailure(filter: filterName) }
        
        return outputCGImage
    }
    
    static func cropAlpha(image: CGImage) throws -> CGImage {
        guard let imageTrimmed = image.trimmingTransparentPixels(maximumAlphaChannel: 150)
        else { throw ImageColorError.cgImageDataFailure }
        
        return imageTrimmed
    }
}
