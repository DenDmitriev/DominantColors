//
//  HSLTests.swift
//  
//
//  Created by Denis Dmitriev on 05.09.2023.
//

import XCTest
@testable import DominantColors

class HSLTests: XCTestCase {
    
    /// https://convertacolor.com for check results

    func testRed() {
        let color = CGColor(red: 1, green: .zero, blue: .zero, alpha: 1)
        
        XCTAssertEqual(color.hue, 0)
        XCTAssertEqual(color.saturation, 100)
        XCTAssertEqual(color.lightness, 50)
    }
    
    func testGreen() {
        let color = CGColor(red: .zero, green: 1, blue: .zero, alpha: 1)
        
        XCTAssertEqual(color.hue, 120)
        XCTAssertEqual(color.saturation, 100)
        XCTAssertEqual(color.lightness, 50)
    }
    
    func testBlue() {
        let color = CGColor(red: .zero, green: .zero, blue: 1, alpha: 1)
        
        XCTAssertEqual(color.hue, 240)
        XCTAssertEqual(color.saturation, 100)
        XCTAssertEqual(color.lightness, 50)
    }
    
    func testWhite() {
        let color = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        XCTAssertEqual(color.hue, 0)
        XCTAssertEqual(color.saturation, 0)
        XCTAssertEqual(color.lightness, 100)
    }
    
    func testBlack() {
        let color = CGColor.black
        
        XCTAssertEqual(color.hue, 0)
        XCTAssertEqual(color.saturation, 0)
        XCTAssertEqual(color.lightness, 0)
    }
    
    func testArbitrary() {
        let color = CGColor(red: 129.0 / 255.0, green: 200.0 / 255.0, blue: 10.0 / 255.0, alpha: 1.0)
        
        let roundHue = color.hue.rounded(.toNearestOrAwayFromZero, precision: 10)
        let roundLightness = color.lightness.rounded(.toNearestOrAwayFromZero, precision: 10)
        let roundSaturation = color.saturation.rounded(.toNearestOrAwayFromZero, precision: 10)
        
        XCTAssertEqual(roundHue, 82.4)
        XCTAssertEqual(roundSaturation, 90.5)
        XCTAssertEqual(roundLightness, 41.2)
    }
    
    func testHSLToCGColor() {
        let white = HSL(hue: 0, saturation: 100, lightness: 100)
        XCTAssertEqual(white.cgColor, CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
        
        let gray = HSL(hue: 120, saturation: 0, lightness: 50)
        XCTAssertEqual(gray.cgColor, CGColor(srgbRed: 50 / 100, green: 50 / 100, blue: 50 / 100, alpha: 1.0))
        
        let black = HSL(hue: 240, saturation: 75, lightness: 0)
        XCTAssertEqual(black.cgColor, CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
        
        let red = HSL(hue: 0, saturation: 100, lightness: 50)
        XCTAssertEqual(red.cgColor, CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1.0))
        
        let green = HSL(hue: 120, saturation: 100, lightness: 50)
        XCTAssertEqual(green.cgColor, CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1.0))
        
        let blue = HSL(hue: 240, saturation: 100, lightness: 50)
        XCTAssertEqual(blue.cgColor, CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1.0))
        
        let someYellow = HSL(hue: 47, saturation: 83, lightness: 53)
        let expectationSomeYellow = CGColor(srgbRed: 235 / 255, green: 190 / 255, blue: 33 / 255, alpha: 1.0)
        XCTAssertEqual(someYellow.cgColor.red255, expectationSomeYellow.red255, accuracy: 2)
        XCTAssertEqual(someYellow.cgColor.green255, expectationSomeYellow.green255, accuracy: 2)
        XCTAssertEqual(someYellow.cgColor.blue255, expectationSomeYellow.blue255, accuracy: 3)
    }
}
