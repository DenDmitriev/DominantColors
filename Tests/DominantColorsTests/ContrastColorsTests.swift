//
//  ContrastColorsTests.swift
//
//
//  Created by Denis Dmitriev on 12.05.2024.
//

import XCTest
@testable import DominantColors

final class ContrastColorsTests: XCTestCase {
    
    // MARK: - Colors
    
    func testPaletteNoColors() {
        XCTAssertNil(ContrastColors(colors: []))
    }
    
    func testPaletteOneColor() {
        XCTAssertNil(ContrastColors(colors: [.green]))
    }
    
    func testPaletteSameColors() {
        XCTAssertNil(ContrastColors(colors: [.green, .green, .green, .green]))
    }
    
    func testPaletteBlackWhiteColors() {
        let colorPalette = ContrastColors(colors: [.black, .white])
        XCTAssertEqual(colorPalette?.background, .black)
        XCTAssertEqual(colorPalette?.primary, .white)
        XCTAssertNil(colorPalette?.secondary)
    }
    
    func testPaletteBlackWhiteColorsBright() {
        let colorPalette = ContrastColors(colors: [.black, .white], darkBackground: false)
        XCTAssertEqual(colorPalette?.background, .white)
        XCTAssertEqual(colorPalette?.primary, .black)
        XCTAssertNil(colorPalette?.secondary)
    }
    
    func testCloseColors() {
        XCTAssertNil(ContrastColors(colors: [.blue, CGColor(red: 0, green: 0, blue: 0.8, alpha: 1.0)]))
    }
    
    func testRealUseCase() {
        let darkBlue = CGColor(red: 0.0 / 255.0, green: 120.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
        let brightBlue = CGColor(red: 110.0 / 255.0, green: 178.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
        let orange = CGColor(red: 203.0 / 255.0, green: 179.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
        let colorPalette = ContrastColors(colors: [darkBlue, brightBlue, orange], ignoreContrastRatio: true)
        XCTAssertEqual(colorPalette?.background, darkBlue)
        XCTAssertEqual(colorPalette?.primary, orange)
        XCTAssertEqual(colorPalette?.secondary, brightBlue)
    }
    
    func testRealUseCase2() {
        let red = CGColor(red: 255.0 / 255.0, green: 21.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
        let darkBlue = CGColor(red: 76.0 / 255.0, green: 101.0 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)
        let white = CGColor.white
        let colorPalette = ContrastColors(colors: [red, darkBlue, white], darkBackground: false)
        XCTAssertEqual(colorPalette?.background, white)
        XCTAssertEqual(colorPalette?.primary, darkBlue)
        XCTAssertEqual(colorPalette?.secondary, red)
    }
    
    // MARK: - Ordered Colors
    
    func testPaletteNoOrderedColors() {
        XCTAssertNil(ContrastColors(orderedColors: []))
    }
    
    func testPaletteOneOrderedColor() {
        XCTAssertNil(ContrastColors(orderedColors: [.green]))
    }
    
    func testPaletteSameOrderedColors() {
        XCTAssertNil(ContrastColors(orderedColors: [.green, .green, .green, .green]))
    }
    
    func testPaletteBlackWhiteOrderedColors() {
        let colorPalette = ContrastColors(orderedColors: [.black, .white])
        XCTAssertEqual(colorPalette?.background, .black)
        XCTAssertEqual(colorPalette?.primary, .white)
        XCTAssertNil(colorPalette?.secondary)
    }
    
    func testPaletteWhiteBlackOrderedColorsBright() {
        let colorPalette = ContrastColors(orderedColors: [.white, .black], darkBackground: false)
        XCTAssertEqual(colorPalette?.background, .white)
        XCTAssertEqual(colorPalette?.primary, .black)
        XCTAssertNil(colorPalette?.secondary)
    }
    
    func testPaletteBlackWhiteOrderedColorsBright() {
        let colorPalette = ContrastColors(orderedColors: [.black, .white], darkBackground: false)
        XCTAssertEqual(colorPalette?.background, .black)
        XCTAssertEqual(colorPalette?.primary, .white)
        XCTAssertNil(colorPalette?.secondary)
    }
    
    func testCloseOrderedColors() {
        XCTAssertNil(ContrastColors(orderedColors: [.blue, CGColor(red: 0, green: 0, blue: 0.8, alpha: 1.0)]))
    }
    
    func testRealUseCaseOrdered() {
        let darkBlue = CGColor(red: 0.0 / 255.0, green: 120.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
        let brightBlue = CGColor(red: 110.0 / 255.0, green: 178.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
        let orange = CGColor(red: 203.0 / 255.0, green: 179.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
        let colorPalette = ContrastColors(orderedColors: [darkBlue, brightBlue, orange], ignoreContrastRatio: true)
        XCTAssertEqual(colorPalette?.background, darkBlue)
        XCTAssertEqual(colorPalette?.primary, brightBlue)
        XCTAssertEqual(colorPalette?.secondary, orange)
    }
    
    func testRealUseCase2Ordered() {
        let red = CGColor(red: 255.0 / 255.0, green: 21.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
        let darkBlue = CGColor(red: 76.0 / 255.0, green: 101.0 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)
        let white = CGColor.white
        let colorPalette = ContrastColors(orderedColors: [red, darkBlue, white], darkBackground: false)
        XCTAssertEqual(colorPalette?.background, red)
        XCTAssertEqual(colorPalette?.primary, white)
        XCTAssertNil(colorPalette?.secondary)
    }
    
}
