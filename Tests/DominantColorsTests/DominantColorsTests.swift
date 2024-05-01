//
//  DominantColorsTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 5/19/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class DominantColorsTests: XCTestCase {
    
    func testGreenImage() throws {
        let name = NSImage.Name("Green_Square")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let dominantColors = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        
        XCTAssertEqual(dominantColors.count, 1)
        
        let green = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 1, 0, 1])!
        XCTAssertEqual(dominantColors.first!.color, green)
        guard let distance = dominantColors.first?.color.difference(from: green)
        else {
            XCTFail("Could not get distance from dominant color.")
            return
        }
        XCTAssertLessThan(distance.associatedValue, AverageColorTests.tolerance)
        XCTAssertEqual(dominantColors.first?.frequency, 1.0)
    }
    
    func testBlackWhiteImage() throws {
        let name = NSImage.Name("Black_White_Square")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })
        
        XCTAssertEqual(dominantColors.count, 2)
        
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        XCTAssertTrue(dominantColors.contains(black))
        
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        XCTAssertTrue(dominantColors.contains(white))
        
        verifySorted(colorsFrequencies: colorFrequencies)

        XCTAssertEqual(colorFrequencies.first?.frequency, 0.5)
        XCTAssertEqual(colorFrequencies.last?.frequency, 0.5)
    }
    
    func testRemoveBlackWhite() throws {
        let name = NSImage.Name("Black_White_Red_Green_Blue_Grey")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best, flags: [.excludeBlack, .excludeWhite])
        
        let extractColorAfterBlackWhiteFilter = 5

        XCTAssertEqual(colorFrequencies.count, extractColorAfterBlackWhiteFilter)
    }

    func testRedBlueGreenImage() throws {
        let name = NSImage.Name("Red_Green_Blue")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertEqual(dominantColors.count, 3)
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)))
        verifySorted(colorsFrequencies: colorFrequencies)
    }

    func testRedBlueGreenBlack() throws {
        let name = NSImage.Name("Red_Green_Blue_Black_Mini")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertEqual(dominantColors.count, 4)
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)))
        verifySorted(colorsFrequencies: colorFrequencies)
    }

    func testRedBlueGreenRandom() throws {
        let name = NSImage.Name("Red_Green_Blue_Random_Mini")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)))
        verifySorted(colorsFrequencies: colorFrequencies)
    }
    
    func testImage() throws {
        let name = NSImage.Name("WaterLife1")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let dominantColors = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best, flags: [.excludeBlack, .excludeGray, .excludeWhite])
        
        XCTAssertGreaterThan(dominantColors.count, 12)
    }

    func verifySorted(colorsFrequencies: [ColorFrequency]) {
        var previousCount: CGFloat?

        colorsFrequencies.forEach { (colorFrequency) in
            guard let oldCount = previousCount else {
                previousCount = colorFrequency.frequency
                return
            }

            if oldCount < colorFrequency.frequency {
                XCTFail("The order of the color frenquecy is not correct.")
            }

            previousCount = colorFrequency.frequency
        }
    }
    
}
