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
        let color = CGColor(red: .zero, green: 255, blue: .zero, alpha: 1)
        
        XCTAssertEqual(color.X, 35.76)
        XCTAssertEqual(color.Y, 71.52)
        XCTAssertEqual(color.Z, 11.92)
    }
    
    func testWhite() {
        let color = CGColor.white
        
        XCTAssertEqual(color.X, 95.05)
        XCTAssertEqual(color.Y, 100.0)
        XCTAssertEqual(color.Z, 108.9)
    }
    
    func testArbitrary() {
        let color = CGColor(red: 129.0 / 255.0, green: 200.0 / 255.0, blue: 10.0 / 255.0, alpha: 1.0)
        
        XCTAssertEqual(color.X, 29.76)
        XCTAssertEqual(color.Y, 46.0)
        XCTAssertEqual(color.Z, 7.6)
    }
    
}
