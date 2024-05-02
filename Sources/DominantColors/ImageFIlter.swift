//
//  ImageFilter.swift
//
//
//  Created by Denis Dmitriev on 28.04.2024.
//

import CoreImage
#if os(OSX)
    import AppKit.NSImage
#elseif os(iOS)
import UIKit.UIImage
#endif

class ImageFilter {
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
        
        let context = CIContext()
        
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { throw ImageColorError.ciFilterCreateFailure(filter: filterName) }
        
        return outputCGImage
    }
    
    static func cropAlpha(image: CGImage, by quality: DominantColorQuality = .fair) throws -> CGImage {
        guard let cfData = image.dataProvider?.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        let pixelSize = quality.pixellateScale.intValue
        let width = CGFloat((image.width / pixelSize - 1) * pixelSize)
        let height = CGFloat((image.height / pixelSize - 1) * pixelSize)
        
        var rect = CGRectMake(0, 0, width, height)
        
        outerLoop: for yCoordonate in 0 ..< image.height {
            for xCoordonate in 0 ..< image.width {
                let index = (image.width * yCoordonate + xCoordonate) * 4
                let alpha = data[index + 3]
                if alpha != 0 {
                    rect.origin.x = CGFloat(xCoordonate)
                    rect.origin.y = CGFloat(yCoordonate)
                    break outerLoop
                }
            }
        }
        
        let filterName = "CICrop"
        guard let croppedImage = image.cropping(to: rect)
        else { throw ImageColorError.ciFilterCreateFailure(filter: filterName) }
        
        // For remove alpa after crop from CFData image
        let outputCGImage = try imageRepresentation(cgImage: croppedImage)
        
        return outputCGImage
    }
}


#if os(OSX)
extension ImageFilter {
    // Representation CFData image
    private static func imageRepresentation(cgImage: CGImage) throws -> CGImage {
        let context = CIContext()
        guard let dataCroppedImage = context.pngRepresentation(of: CIImage(cgImage: cgImage), format: .RGBA8, colorSpace: cgImage.colorSpace!),
              let nsImageCroppedImage = NSImage(data: dataCroppedImage),
              let outputCGImage = nsImageCroppedImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { throw ImageColorError.ciFilterCreateFailure(filter: #function) }
        
        return outputCGImage
    }
}
#elseif os(iOS)
extension ImageFilter {
    // Representation CFData image
    private static func imageRepresentation(cgImage: CGImage) throws -> CGImage {
        let context = CIContext()
        guard let dataCroppedImage = context.pngRepresentation(of: CIImage(cgImage: cgImage), format: .RGBA8, colorSpace: cgImage.colorSpace!),
              let uiImageCroppedImage = UIImage(data: dataCroppedImage),
              let outputCGImage = uiImageCroppedImage.cgImage
        else { throw ImageColorError.ciFilterCreateFailure(filter: #function) }
        
        return outputCGImage
    }
}
#endif

