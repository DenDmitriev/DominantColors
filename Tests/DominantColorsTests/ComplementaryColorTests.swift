//
//  ComplementaryColorTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 3/18/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class ComplementaryColorTests: XCTestCase {

    func testBlack() {
        let black = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        let complementaryColor = black.complementaryColor
        XCTAssertEqual(complementaryColor.components, CGColor(red: 1, green: 1, blue: 1, alpha: 1.0).components)
    }
    
    func testWhite() {
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        let complementaryColor = white.complementaryColor
        XCTAssertEqual(complementaryColor.components, CGColor(red: 0, green: 0, blue: 0, alpha: 1.0).components)
    }
    
    func testBlue() {
        let blue = CGColor(red: .zero, green: .zero, blue: 1, alpha: 1.0)
        let complementaryColor = blue.complementaryColor
        XCTAssertEqual(complementaryColor.components, CGColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0, alpha: 1.0).components)
    }
    
    func testYellow() {
        let yellow = CGColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0, alpha: 1.0)
        let complementaryColor = yellow.complementaryColor
        XCTAssertEqual(complementaryColor.components, CGColor(red: .zero, green: .zero, blue: 255, alpha: 1.0).components)
    }
    
    func testRed() {
        let red = CGColor(red: 1, green: .zero, blue: .zero, alpha: 1.0)
        let complementaryColor = red.complementaryColor
        XCTAssertEqual(complementaryColor.components, CGColor(red: 0.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).components)
    }
        
}
