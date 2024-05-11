//
//  FilterImageTests.swift
//  
//
//  Created by Denis Dmitriev on 26.04.2024.
//

import XCTest
@testable import DominantColors

#if os(OSX)
final class FilterImageTests: XCTestCase {

    func testPixellate() throws {
        let name = NSImage.Name("Pixeleate_Image")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let quality: DominantColorQuality = .fair
        let pixellateImage = try ImageFilter.pixellate(image: cgImage, by: quality)
        
        let size = CGSize(width: pixellateImage.width, height: pixellateImage.height)
        let expectationSize = CGSize(width: 96, height: 96)
        XCTAssertEqual(size, expectationSize)
    }
    
    func testCropAlpha() throws {
        let name = NSImage.Name("Test_Crop_Alpha")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let croppedImage = try ImageFilter.cropAlpha(image: cgImage)
        
        let size = CGSize(width: croppedImage.width, height: croppedImage.height)
        let expectationSize = CGSize(width: 32, height: 32)
        XCTAssertEqual(size, expectationSize)
        
        guard let cfData = croppedImage.dataProvider!.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        var colorsOnImage: [CGColor] = []
        for yCoordonate in 0 ..< croppedImage.height {
            for xCoordonate in 0 ..< croppedImage.width {
                let index = (croppedImage.width * yCoordonate + xCoordonate) * 4
                
                let alpha = CGFloat(data[index + 3])
                let red = CGFloat(data[index + 0])
                let green = CGFloat(data[index + 1])
                let blue = CGFloat(data[index + 2])
                
                let pixelColor = CGColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
                colorsOnImage.append(pixelColor)
            }
        }
        
        let alphaColors = colorsOnImage.filter({ $0.alpha == 0 })
        XCTAssert(alphaColors.isEmpty)
    }
}
#endif
