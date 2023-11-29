//
//  ImageColorError.swift
//  
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import Foundation

enum ImageColorError: Error {
    /// The `CIImage` instance could not be created.
    case ciImageFailure
    
    /// The `CGImage` instance could not be created.
    case cgImageFailure
    
    /// Failed to get the pixel data from the `CGImage` instance.
    case cgImageDataFailure
    
    /// An error happened during the creation of the image after applying the filter.
    case outputImageFailure
    
    /// Can't create CIFilter(name: "FILTER_KEY")
    case ciFilterCreateFailure(filter: String)
    
    /// The singleton CFNull (special memory address) object is nil
    case kCFNullFailure
    
    /// The resolution of the image is less than the requested number of colors
    case lowResolutionFailure
    
    /// The `CGColor` instance could not be created.
    case cgColorFailure
}

extension ImageColorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .ciImageFailure:
            return "Failed to get a `CIImage` instance."
        case .cgImageFailure:
            return "Failed to get a `CGImage` instance."
        case .cgImageDataFailure:
            return "Failed to get image data."
        case .outputImageFailure:
            return "Could not get the output image from the filter."
        case .ciFilterCreateFailure(let filter):
            return "Failed to create CIFilter \(filter)."
        case .kCFNullFailure:
            return "The singleton CFNull (special memory address) object is nil."
        case .lowResolutionFailure:
            return "The resolution of the image is less than the requested number of colors"
        case .cgColorFailure:
            return "Failed create cg color or color space for color."
        }
    }
}
