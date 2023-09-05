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
        
        let roundHue = (color.hue * 10).rounded() / 10
        let roundLightness = (color.lightness * 10).rounded() / 10
        let roundSaturation = (color.saturation * 10).rounded() / 10
        
        XCTAssertEqual(roundHue, 82.4)
        XCTAssertEqual(roundSaturation, 90.5)
        XCTAssertEqual(roundLightness, 41.2)
    }
}
