//
//  XYZTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/24/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

/// http://www.brucelindbloom.com/index.html?ColorCalculator.html
class XYZTests: XCTestCase {

    func testRed() {
        let red = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [1, 0, 0, 1])!
        
        XCTAssertEqual(red.X, 41.2456)
        XCTAssertEqual(red.Y, 21.2673)
        XCTAssertEqual(red.Z, 1.9334)
    }
    
    func testGreen() {
        let green = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 1, 0, 1])!
        
        XCTAssertEqual(green.X, 35.7576)
        XCTAssertEqual(green.Y, 71.5152)
        XCTAssertEqual(green.Z, 11.9192)
    }
    
    func testBlue() {
        let blue = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 0, 1, 1])!
        
        XCTAssertEqual(blue.X, 18.0438)
        XCTAssertEqual(blue.Y, 7.2175)
        XCTAssertEqual(blue.Z, 95.0304)
    }
    
    func testWhite() {
        let white = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [1, 1, 1, 1])!
        
        XCTAssertEqual(white.X, 95.0470)
        XCTAssertEqual(white.Y, 100)
        XCTAssertEqual(white.Z, 108.8830)
    }
    
    func testBlack() {
        let black = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 0, 0, 1])!
        
        XCTAssertEqual(black.X, 0)
        XCTAssertEqual(black.Y, 0)
        XCTAssertEqual(black.Z, 0)
    }
    
    func testArbitrary() {
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [129.0 / 255.0, 200.0 / 255.0, 10.0 / 255.0, 1])!
        
        XCTAssertEqual(color.X, 29.7622)
        XCTAssertEqual(color.Y, 45.9964)
        XCTAssertEqual(color.Z, 7.5972)
    }
    
}
