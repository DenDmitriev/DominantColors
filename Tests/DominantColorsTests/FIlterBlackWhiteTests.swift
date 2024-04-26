//
//  FIlterBlackWhiteTests.swift
//  
//
//  Created by Denis Dmitriev on 26.04.2024.
//

import XCTest
import SwiftUI
@testable import DominantColors

final class FIlterBlackWhiteTests: XCTestCase {
    
    static let blackMaxLightness: CGFloat = 10
    static let whiteMinLightness: CGFloat = 90
    
    static let blackMaxDeltaCIE76: CGFloat = 10

    func testFilterBlack() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for (index, lightness) in stride(from: 0, to: 1.1, by: 0.1).enumerated() {
            let hsl = HSL(hue: 0, saturation: 0, lightness: CGFloat(lightness).rounded(.toNearestOrAwayFromZero, precision: 10))
            let color = Color(hue: hsl.hue, saturation: hsl.saturation, brightness: hsl.lightness).cgColor!
            colors.append(ColorFrequency(index: index, color: color, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        DominantColors.filterBlack(max: Self.blackMaxLightness, colors: &colors)
        XCTAssertEqual(colors.count, 9)
    }
    
    func testFilterWhite() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for (index, lightness) in stride(from: 0, to: 1.1, by: 0.1).enumerated() {
            let hsl = HSL(hue: 0, saturation: 0, lightness: CGFloat(lightness).rounded(.toNearestOrAwayFromZero, precision: 10))
            let color = Color(hue: hsl.hue, saturation: hsl.saturation, brightness: hsl.lightness).cgColor!
            colors.append(ColorFrequency(index: index, color: color, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        DominantColors.filterWhite(min: Self.whiteMinLightness, colors: &colors)
        
        XCTAssertEqual(colors.count, 9)
    }
    
    func testFilterBlackDeltaDifference() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for (index, lightness) in stride(from: 0, to: 1.1, by: 0.1).enumerated() {
            let hsl = HSL(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), lightness: CGFloat(lightness).rounded(.toNearestOrAwayFromZero, precision: 10))
            let color = Color(hue: hsl.hue, saturation: hsl.saturation, brightness: hsl.lightness).cgColor!
            colors.append(ColorFrequency(index: index, color: color, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        DominantColors.filterBlack(delta: Self.blackMaxDeltaCIE76, colors: &colors, using: .CIE76)
        XCTAssertEqual(colors.count, 9)
    }
    
    func testFilterWhiteDeltaDifference() throws {
        var colors = [ColorFrequency]()
        // Create colors with brightness from 0 to 10
        for (index, lightness) in stride(from: 0, to: 1.1, by: 0.1).enumerated() {
            let hsl = HSL(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), lightness: CGFloat(lightness).rounded(.toNearestOrAwayFromZero, precision: 10))
            let color = Color(hue: hsl.hue, saturation: hsl.saturation, brightness: hsl.lightness).cgColor!
            colors.append(ColorFrequency(index: index, color: color, count: 1))
        }
        XCTAssertEqual(colors.count, 11)
        
        DominantColors.filterBlack(delta: Self.blackMaxDeltaCIE76, colors: &colors, using: .CIE76)
        XCTAssertEqual(colors.count, 9)
    }
}
