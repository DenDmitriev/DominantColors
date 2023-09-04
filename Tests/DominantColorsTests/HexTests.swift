//
//  HexTests.swift
//  ColorKitTests
//
//  Created by Boris Emorine on 2/27/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import XCTest
@testable import DominantColors

class HexTests: XCTestCase {
    
    private let blackHex = "#000000"
    private let whiteHex = "#ffffff"
    private let redHex = "#ff0000"
    private let darkGreen = "#32a852"
    private let lightGreen = "#43ff64d9"

    // Init
    
    func testInitBlack() {
        let hexColor = Hex(hex: blackHex)!
        XCTAssertEqual(hexColor.cgColor.red, 0)
        XCTAssertEqual(hexColor.cgColor.green, 0)
        XCTAssertEqual(hexColor.cgColor.blue, 0)
        XCTAssertEqual(hexColor.cgColor.alpha, 1)
    }
    
    func testInitWhite() {
        let hexColor = Hex(hex: whiteHex)!
        XCTAssertEqual(hexColor.cgColor.red, 1)
        XCTAssertEqual(hexColor.cgColor.green, 1)
        XCTAssertEqual(hexColor.cgColor.blue, 1)
        XCTAssertEqual(hexColor.cgColor.alpha, 1)
    }
    
    func testInitRed() {
        let hexColor = Hex(hex: redHex)!
        XCTAssertEqual(hexColor.cgColor.red, 255.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.green, 0.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.blue, 0.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.alpha, 1)
    }
    
    func testInitDarkGreen() {
        let hexColor = Hex(hex: darkGreen)!
        XCTAssertEqual(hexColor.cgColor.red, 50.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.green, 168.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.blue, 82.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.alpha, 1)
    }
    
    func testInitLightGreen() {
        let hexColor = Hex(hex: lightGreen)!
        XCTAssertEqual(hexColor.cgColor.red, 67.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.green, 255.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.blue, 100.0 / 255.0)
        XCTAssertEqual(hexColor.cgColor.alpha, 0.85, accuracy: 0.001)
    }
    
    // hex
    
    func testHexBlack() {
        let color = CGColor.black
        let hex = Hex(cgColor: color)
        XCTAssertEqual(hex.hex, blackHex)
    }
    
    func testHexWhite() {
        let color = CGColor.white
        let hex = Hex(cgColor: color)
        XCTAssertEqual(hex.hex, whiteHex)
    }
    
    func testHexRed() {
        let color = CGColor(red: 255, green: .zero, blue: .zero, alpha: 1)
        let hex = Hex(cgColor: color)
        XCTAssertEqual(hex.hex, redHex)
    }
    
    func testHexDarkGreen() {
        let color = CGColor(red: 50.0 / 255.0, green: 168.0 / 255.0, blue: 82.0 / 255.0, alpha: 1.0)
        let hex = Hex(cgColor: color)
        XCTAssertEqual(hex.hex, darkGreen)
    }
    
}
