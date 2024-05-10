//
//  ColorDifferenceTest.swift
//  
//
//  Created by Denis Dmitriev on 10.05.2024.
//
// Used Color Difference Calculator
// http://www.brucelindbloom.com/index.html?ColorCalculator.html
//
// Lab Reference red: Lab(53.2408, 80.0923, 67.2031)
// Lab Sample green: (87.7347, -86.1827, 83.1793)
// CIE 1976: 170.56507
// CIE 1994: 73.430412 (Graphic Arts)
// CIE 2000: 86.608180 (1:1:1)
// CMC: 108.44909 (1:1)

import XCTest
@testable import DominantColors

final class ColorDifferenceTest: XCTestCase {

    func testDeltaCIE76() throws {
        let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        let green = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        
        let deltaCIE76 = red.difference(from: green, using: .CIE76)
        XCTAssertEqual(deltaCIE76.associatedValue, 170, accuracy: 1)
    }
    
    func testDeltaCIE94() throws {
        let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        let green = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        
        let deltaCIE94 = red.difference(from: green, using: .CIE94)
        XCTAssertEqual(deltaCIE94.associatedValue, 73, accuracy: 1)
    }
    
    func testDeltaCIEDE2000() throws {
        let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        let green = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        
        let deltaCIEDE2000 = red.difference(from: green, using: .CIEDE2000)
        XCTAssertEqual(deltaCIEDE2000.associatedValue, 86, accuracy: 1)
    }
    
    func testDeltaCMC() throws {
        let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        let green = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        
        let deltaCMC = red.difference(from: green, using: .CMC)
        XCTAssertEqual(deltaCMC.associatedValue, 108, accuracy: 1)
    }

}
