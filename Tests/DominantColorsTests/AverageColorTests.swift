//
//  AverageColorTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 5/15/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class AverageColorTests: XCTestCase {

    static let tolerance: CGFloat = 0.5
    
    /// It should compute a green average color for a green image.
    func testGreenImage() throws {
        let name = NSImage.Name("Green_Square")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!

        let averageColor = try AverageColor.averageColor(image: cgImage)

        let distance = averageColor.difference(from: CGColor(red: .zero, green: 1, blue: .zero, alpha: 1.0))
        XCTAssertLessThan(distance.associatedValue, AverageColorTests.tolerance)
    }
    
    /// It should compute a purple average color for a purple image.
    func testPurpleImage() throws {
        let name = NSImage.Name("Purple_Square")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let averageColor = try AverageColor.averageColor(image: cgImage)

        let expectedPurple = CGColor(red: 208.0 / 255.0, green: 0.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        let distance = averageColor.difference(from: expectedPurple)
        XCTAssertLessThan(distance.associatedValue, AverageColorTests.tolerance)
    }
    
    /// It should compute a gray average color for a black & white image.
    func testBlackWhiteImage() throws {
        let name = NSImage.Name("Black_White_Square")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let averageColor = try AverageColor.averageColor(image: cgImage)

        let expectedGray = CGColor(red: 188.0 / 255.0, green: 188.0 / 255.0, blue: 188.0 / 255.0, alpha: 1.0)
        let distance = averageColor.difference(from: expectedGray)
        XCTAssertLessThan(distance.associatedValue, AverageColorTests.tolerance)
    }
    
}
