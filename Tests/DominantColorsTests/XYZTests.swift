//
//  XYZTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/24/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class XYZTests: XCTestCase {

    func testGreen() {
        let green = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 1, 0, 1])!
        
        XCTAssertEqual(green.X, 35.76)
        XCTAssertEqual(green.Y, 71.52)
        XCTAssertEqual(green.Z, 11.92)
    }
    
    func testWhite() {
        let white = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [1, 1, 1, 1])!
        
        XCTAssertEqual(white.X, 95.05)
        XCTAssertEqual(white.Y, 100.0)
        XCTAssertEqual(white.Z, 108.9)
    }
    
    func testArbitrary() {
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [129.0 / 255.0, 200.0 / 255.0, 10.0 / 255.0, 1])!
        
        XCTAssertEqual(color.X, 29.76)
        XCTAssertEqual(color.Y, 46.0)
        XCTAssertEqual(color.Z, 7.6)
    }
    
}
