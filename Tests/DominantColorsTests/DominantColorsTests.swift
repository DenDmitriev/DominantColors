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
        guard let distance = dominantColors.first?.color.difference(
            from: CGColor(red: .zero, green: 1.0, blue: .zero, alpha: 1.0)
        ) else {
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
        
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 255)
        XCTAssertTrue(dominantColors.contains(black))
        
        let white = CGColor(srgbRed: 255, green: 255, blue: 255, alpha: 255)
        XCTAssertTrue(dominantColors.contains(white))
        
        verifySorted(colorsFrequencies: colorFrequencies)

        XCTAssertEqual(colorFrequencies.first?.frequency, 0.5)
        XCTAssertEqual(colorFrequencies.last?.frequency, 0.5)
    }
    
    func testRemoveBlackWhite() throws {
        let name = NSImage.Name("Black_White_Red_Green_Blue_Grey")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        var colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        
        let extractColorAfterBlackWhiteFilter = 5
        
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 255)
        let white = CGColor(srgbRed: 255, green: 255, blue: 255, alpha: 255)
        
        colorFrequencies.removeAll { colorFrequency in
            let difference = black.difference(from: colorFrequency.color)
            if difference < .near(10) || difference < .indentical(.zero) {
                return true
            } else {
                return false
            }
        }
        
        colorFrequencies.removeAll { colorFrequency in
            let difference = white.difference(from: colorFrequency.color)
            if difference < .near(10) || difference < .indentical(.zero)  {
                return true
            } else {
                return false
            }
        }
        
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertEqual(dominantColors.count, extractColorAfterBlackWhiteFilter)
    }

    func testRedBlueGreenImage() throws {
        let name = NSImage.Name("Red_Green_Blue")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertEqual(dominantColors.count, 3)
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 255, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 255)))
        verifySorted(colorsFrequencies: colorFrequencies)
    }

    func testRedBlueGreenBlack() throws {
        let name = NSImage.Name("Red_Green_Blue_Black_Mini")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertEqual(dominantColors.count, 4)
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 255, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 255)))
        verifySorted(colorsFrequencies: colorFrequencies)
    }

    func testRedBlueGreenRandom() throws {
        let name = NSImage.Name("Red_Green_Blue_Random_Mini")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let colorFrequencies = try DominantColors.dominantColorFrequencies(image: cgImage, with: .best)
        let dominantColors = colorFrequencies.map({ $0.color })

        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 255, blue: 0, alpha: 255)))
        XCTAssertTrue(dominantColors.contains(CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 255)))
        verifySorted(colorsFrequencies: colorFrequencies)
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
