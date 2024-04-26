//
//  LabTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/26/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest

/// https://cielab.xyz/colorconv/
class LabTests: XCTestCase {

    func testRed() {
        let color = CGColor(red: 1, green: .zero, blue: .zero, alpha: 1)
        
        XCTAssertEqual(color.L, 53.2408)
        XCTAssertEqual(color.a, 80.0923)
        XCTAssertEqual(color.b, 67.2031)
    }
    
    func testGreen() {
        let color = CGColor(red: .zero, green: 1, blue: .zero, alpha: 1)
        
        XCTAssertEqual(color.L, 87.7347)
        XCTAssertEqual(color.a, -86.1827)
        XCTAssertEqual(color.b, 83.1793)
    }
    
    func testBlue() {
        let color = CGColor(red: .zero, green: .zero, blue: 1, alpha: 1)
        
        XCTAssertEqual(color.L, 32.2970)
        XCTAssertEqual(color.a, 79.1878)
        XCTAssertEqual(color.b, -107.8602)
    }
    
    func testWhite() {
        let color = CGColor.white
        
        XCTAssertEqual(color.L, 100)
        XCTAssertEqual(color.a, 0)
        XCTAssertEqual(color.b, 0)
    }
    
    func testBlack() {
        let color = CGColor.black
        
        XCTAssertEqual(color.L, 0)
        XCTAssertEqual(color.a, 0)
        XCTAssertEqual(color.b, 0)
    }
    
    func testArbitrary() {
        let color = CGColor(red: 235 / 255.0, green: 87 / 255.0, blue: 87 / 255.0, alpha: 1.0)
        
        XCTAssertEqual(color.L, 57.2426)
        XCTAssertEqual(color.a, 57.0894)
        XCTAssertEqual(color.b, 30.9286)
    }
    
}
