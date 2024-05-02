//
//  ExtractColorsTests.swift
//  
//
//  Created by Denis Dmitriev on 26.04.2024.
//

import XCTest
@testable import DominantColors

#if os(OSX)
final class ExtractColorsTests: XCTestCase {

    func testExtractColors() throws {
        let name = NSImage.Name("Pixeleate_Image")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let colors = try DominantColors.extractColors(cgImage)
        
        XCTAssertEqual(colors.count, 4)
        XCTAssertEqual(colors.count(for: RGB255(red: 235, green: 87, blue: 87)), 32 * 32)
        XCTAssertEqual(colors.count(for: RGB255(red: 47, green: 128, blue: 237)), 32 * 32)
        XCTAssertEqual(colors.count(for: RGB255(red: 33, green: 150, blue: 83)), 32 * 32)
        XCTAssertEqual(colors.count(for: RGB255(red: 155, green: 81, blue: 224)), 32 * 32)
    }
    
    func testExtractColorsFromPixellateImage() throws {
        let name = NSImage.Name("Pixeleate_Image")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let colors = try DominantColors.extractColors(pixellate: cgImage, pixelSize: 32)
        
        XCTAssertEqual(colors.count, 4)
        XCTAssertEqual(colors.count(for: RGB255(red: 235, green: 87, blue: 87)), 1)
        XCTAssertEqual(colors.count(for: RGB255(red: 47, green: 128, blue: 237)), 1)
        XCTAssertEqual(colors.count(for: RGB255(red: 33, green: 150, blue: 83)), 1)
        XCTAssertEqual(colors.count(for: RGB255(red: 155, green: 81, blue: 224)), 1)
    }
}
#endif
