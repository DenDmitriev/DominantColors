//
//  ComparisonTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/24/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class ComparisonTests: XCTestCase {
    
    // MARK: - Euclidean
    
    func testWhiteWhiteEuclidean() {
        let color1 = CGColor.white
        let color2 = CGColor.white
        
        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testPurplePurpleEuclidean() {
        let color1 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        let color2 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testWhiteBlackEuclidean() {
        let color1 = CGColor.white
        let color2 = CGColor.black
        
        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 441.67)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testRandomEuclidean() {
        let color1 = CGColor(red: 76.5 / 255.0, green: 127.5 / 255.0, blue: 178.5 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 127.5 / 255.0, green: 25.5 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 171.06)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testCloseEuclidean() {
        let color1 = CGColor(red: 196.0 / 255.0, green: 199.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 171.0 / 255.0, green: 173.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 36.29)

        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    // MARK: - CIE76
    
    func testWhiteWhiteCIE76() {
        let color1 = CGColor.white
        let color2 = CGColor.white
        
        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testPurplePurpleCIE76() {
        let color1 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        let color2 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testWhiteBlackCIE76() {
        let color1 = CGColor.white
        let color2 = CGColor.black
        
        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 100.0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testRandomCIE76() {
        let color1 = CGColor(red: 76.5 / 255.0, green: 127.5 / 255.0, blue: 178.5 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 127.5 / 255.0, green: 25.5 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 67.55)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testCloseCIE76() {
        let color1 = CGColor(red: 196.0 / 255.0, green: 199.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 171.0 / 255.0, green: 173.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 14.25)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    // MARK: - CIE94
    
    func testWhiteWhiteCIE94() {
        let color1 = CGColor.white
        let color2 = CGColor.white
        
        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testPurplePurpleCIE94() {
        let color1 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        let color2 = CGColor(red: 128, green: .zero, blue: 128, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testWhiteBlackCIE94() {
        let color1 = CGColor.white
        let color2 = CGColor.black
        
        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 100.0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testRandomCIE94() {
        let color1 = CGColor(red: 76.5 / 255.0, green: 127.5 / 255.0, blue: 178.5 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 127.5 / 255.0, green: 25.5 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 48.31)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, 43.99)
    }
    
    func testCloseCIE94() {
        let color1 = CGColor(red: 196.0 / 255.0, green: 199.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 171.0 / 255.0, green: 173.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 9.5)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, 9.6)
    }


}
