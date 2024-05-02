//
//  FilterBlackWhiteTests.swift
//
//
//  Created by Denis Dmitriev on 26.04.2024.
//

import XCTest
import SwiftUI
@testable import DominantColors

final class FilterBlackWhiteTests: XCTestCase {
    
    static let blackMaxLightness: CGFloat = 10
    static let whiteMinLightness: CGFloat = 90
    
    static let blackMaxDeltaCIE76: CGFloat = 10

    func testFilterBlack() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for lightness in stride(from: 0, to: 1.1, by: 0.1) {
            let cgColor = CGColor(srgbRed: lightness, green: lightness, blue: lightness, alpha: 1.0)
            colors.append(ColorFrequency(color: cgColor, count: 1))
        }
        
        XCTAssertEqual(colors.count, 11)
        
        let blackColors = DominantColors.removeBlack(max: Self.blackMaxLightness, colors: &colors).map { $0.color }
        XCTAssertEqual(colors.count, 9)
        
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        XCTAssertTrue(blackColors.contains(black))
        
        let almostBlack = CGColor(srgbRed: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        XCTAssertTrue(blackColors.contains(almostBlack))
    }
    
    func testFilterWhite() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for lightness in stride(from: 0, to: 1.1, by: 0.1) {
            let cgColor = CGColor(srgbRed: lightness, green: lightness, blue: lightness, alpha: 1.0)
            colors.append(ColorFrequency(color: cgColor, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        let whiteColors = DominantColors.removeWhite(min: Self.whiteMinLightness, colors: &colors).map { $0.color }
        
        XCTAssertEqual(colors.count, 9)
        
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        XCTAssertTrue(whiteColors.contains(white))
        
        let almostWhite = CGColor(srgbRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        XCTAssertTrue(whiteColors.contains(almostWhite))
    }
    
    func testFilterBlackDeltaDifference() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for lightness in stride(from: 0, to: 1.1, by: 0.1) {
            let cgColor = CGColor(srgbRed: lightness, green: lightness, blue: lightness, alpha: 1.0)
            colors.append(ColorFrequency(color: cgColor, count: 1))
        }
        colors.sort(by: { $0.frequency > $1.frequency })
        XCTAssertEqual(colors.count, 11)
        
        let blackColors = DominantColors.removeBlack(delta: Self.blackMaxDeltaCIE76, colors: &colors, using: .CIE76).map { $0.color }
        XCTAssertEqual(colors.count, 9)
        
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        XCTAssertTrue(blackColors.contains(black))
        
        let almostBlack = CGColor(srgbRed: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        XCTAssertTrue(blackColors.contains(almostBlack))
    }
    
    func testFilterWhiteDeltaDifference() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for lightness in stride(from: 0, to: 1.1, by: 0.1) {
            let cgColor = CGColor(srgbRed: lightness, green: lightness, blue: lightness, alpha: 1.0)
            colors.append(ColorFrequency(color: cgColor, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        let whiteColors = DominantColors.removeWhite(delta: Self.blackMaxDeltaCIE76, colors: &colors, using: .CIE76).map { $0.color }
        XCTAssertEqual(colors.count, 9)
        
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        XCTAssertTrue(whiteColors.contains(white))
        
        let almostWhite = CGColor(srgbRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        XCTAssertTrue(whiteColors.contains(almostWhite))
    }
}
