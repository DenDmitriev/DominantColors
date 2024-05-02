//
//  ComparisonTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/24/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

/// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_Lab.html
#if os(OSX)
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
        let color1 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        let color2 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testWhiteBlackEuclidean() {
        let color1 = CGColor.white
        let color2 = CGColor.black
        
        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 441.673)
        
        let reversedDifference = color2.difference(from: color1, using: .euclidean).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testRandomEuclidean() {
        let color1 = CGColor(red: 76.5 / 255.0, green: 127.5 / 255.0, blue: 178.5 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 127.5 / 255.0, green: 25.5 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .euclidean).associatedValue
        XCTAssertEqual(difference, 171.059)
        
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
        let color1 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        let color2 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        
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
        XCTAssertEqual(difference, 67.584)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE76).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testCloseCIE76() {
        let color1 = CGColor(red: 196.0 / 255.0, green: 199.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 171.0 / 255.0, green: 173.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE76).associatedValue
        XCTAssertEqual(difference, 14.263)
        
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
        let color1 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        let color2 = CGColor(red: 128 / 255, green: .zero, blue: 128 / 255, alpha: 1.0)
        
        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testWhiteBlackCIE94() {
        let color1 = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        let color2 = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 100.0)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, difference)
    }
    
    func testRandomCIE94() {
        let color1 = CGColor(red: 76.5 / 255.0, green: 127.5 / 255.0, blue: 178.5 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 127.5 / 255.0, green: 25.5 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 48.329)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, 43.988)
    }
    
    func testCloseCIE94() {
        let color1 = CGColor(red: 196.0 / 255.0, green: 199.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
        let color2 = CGColor(red: 171.0 / 255.0, green: 173.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)

        let difference = color1.difference(from: color2, using: .CIE94).associatedValue
        XCTAssertEqual(difference, 9.511)
        
        let reversedDifference = color2.difference(from: color1, using: .CIE94).associatedValue
        XCTAssertEqual(reversedDifference, 9.607)
    }
}
#endif
