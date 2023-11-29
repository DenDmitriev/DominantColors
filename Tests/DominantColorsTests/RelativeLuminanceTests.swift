//
//  RelativeLuminanceTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 3/13/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class RelativeLuminanceTests: XCTestCase {

    func testWhite() {
        let white = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [1, 1, 1, 1])!
        XCTAssertEqual(white.relativeLuminance, 1.0)
    }
    
    func testBlack() {
        let black = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [0, 0, 0, 1])!
        XCTAssertEqual(black.relativeLuminance, 0.0)
    }
    
    func testOrange() {
        let orange = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [98.0 / 255.0, 44.0 / 255.0, 8.0 / 255.0, 1.0])!
        XCTAssertEqual(orange.relativeLuminance, 0.044)
    }
    
    func testPurple() {
        let purple = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: [120 / 255.0, 90.0 / 255.0, 200.0 / 255.0, 1.0])!
        XCTAssertEqual(purple.relativeLuminance, 0.155)
    }
    
}
