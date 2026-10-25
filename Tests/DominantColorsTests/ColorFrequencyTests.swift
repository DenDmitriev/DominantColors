//
//  ColorFrequencyTests.swift
//  
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import XCTest
@testable import DominantColors

final class ColorFrequencyTests: XCTestCase {
    
    func testFrequency() throws {
        let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1.0)
        let colorFrequencyRed = ColorFrequency(color: red, count: 1)
        XCTAssertEqual(colorFrequencyRed.frequency, 1)
        
        let green = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1.0)
        let colorFrequencyGreen = ColorFrequency(color: green, count: 2)
        XCTAssertEqual(colorFrequencyGreen.frequency, 2)
        
        let blue = CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1.0)
        let colorFrequencyBlue = ColorFrequency(color: blue, count: 3)
        XCTAssertEqual(colorFrequencyBlue.frequency, 3)
    }

    func testNormalFactor() throws {
        // HSL(0, 75, 50)
        let color = CGColor(srgbRed: 223 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1.0)
        let colorFrequency = ColorFrequency(color: color, count: 1)
        let normal = colorFrequency.normal
        
        XCTAssertEqual(colorFrequency.frequency, 1)
        XCTAssertEqual(colorFrequency.normalSaturationFactor, 1)
        XCTAssertEqual(colorFrequency.normalLightnessFactor, 1)
        XCTAssertEqual(normal, colorFrequency.frequency * 1 * 1)
    }
    
    func testNoNormalFactor() throws {
        // HSL(0, 0, 0)
        let color = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        let colorFrequency = ColorFrequency(color: color, count: 1)
        let normal = colorFrequency.normal
        
        XCTAssertEqual(colorFrequency.frequency, 1)
        XCTAssertEqual(colorFrequency.normalSaturationFactor, 0)
        XCTAssertEqual(colorFrequency.normalLightnessFactor, 0)
        XCTAssertEqual(normal, colorFrequency.frequency * 0 * 0)
    }
    
    func testAlmostNormalFactor() throws {
        // HSL(0, 25, 75)
        let color = CGColor(srgbRed: 207 / 255, green: 175 / 255, blue: 175 / 255, alpha: 1.0)
        let colorFrequency = ColorFrequency(color: color, count: 1)
        let normal = colorFrequency.normal
        
        XCTAssertEqual(colorFrequency.frequency, 1)
        XCTAssertEqual(colorFrequency.normalSaturationFactor, 0.33)
        XCTAssertEqual(colorFrequency.normalLightnessFactor, 0.5)
        XCTAssertEqual(normal, colorFrequency.frequency * 0.33 * 0.5)
    }
    
    func testChangingColorUpdatesNormalAndLab() throws {
        // HSL(0, 75, 50)
        let normalColor = CGColor(srgbRed: 223 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1.0)
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        let colorFrequency = ColorFrequency(color: normalColor, count: 1)
        XCTAssertEqual(colorFrequency.normal, 1)
        let normalLab = colorFrequency.lab
        
        colorFrequency.color = black
        
        XCTAssertEqual(colorFrequency.normal, 0)
        XCTAssertNotEqual(colorFrequency.lab.L, normalLab.L)
        XCTAssertEqual(colorFrequency.lab.L, 0, accuracy: 0.001)
    }
    
    /// `normal` must be computed as `frequency * lightness * saturation`, one factor at a time:
    /// a different grouping can differ in the last bit, which reorders colors whose `normal` values tie.
    func testNormalIsComputedFactorByFactor() throws {
        for red in stride(from: 0, through: 255, by: 17) {
            for green in stride(from: 0, through: 255, by: 17) {
                for blue in stride(from: 0, through: 255, by: 51) {
                    let color = CGColor(srgbRed: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
                    for count in [1, 3, 7, 11, 23, 37, 101] as [CGFloat] {
                        let colorFrequency = ColorFrequency(color: color, count: count)
                        let expected = count * colorFrequency.normalLightnessFactor * colorFrequency.normalSaturationFactor
                        XCTAssertEqual(colorFrequency.normal, expected, "\(red) \(green) \(blue) x \(count)")
                    }
                }
            }
        }
    }
}
