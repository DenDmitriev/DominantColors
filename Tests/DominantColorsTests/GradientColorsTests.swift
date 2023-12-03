//
//  GradientColorsTests.swift
//  
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import XCTest
@testable import DominantColors

final class GradientColorsTests: XCTestCase {

    func testColorsAtEdgesPercentage() throws {
        let colors: [CGColor] = [
            .init(red: 0, green: 0, blue: 0, alpha: 1),
            .init(red: 1, green: 0, blue: 0, alpha: 1)
        ]
        
        let colorAtStart = colors.gradientColor(percent: 0)
        let colorAtFinal = colors.gradientColor(percent: 100)
        
        XCTAssertEqual(colorAtStart, colors.first)
        XCTAssertEqual(colorAtFinal, colors.last)
    }
    
    func testColorsAtEdgesSize() throws {
        let colors: [CGColor] = [
            .init(red: 0, green: 1, blue: 0, alpha: 1),
            .init(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        
        let colorAtStart = colors.gradientColor(at: 1, size: 3)
        let colorAtFinal = colors.gradientColor(at: 3, size: 3)
        
        XCTAssertEqual(colorAtStart, colors.first)
        XCTAssertEqual(colorAtFinal, colors.last)
    }
    
    func testColorAtMiddlePercentage() throws {
        let colors: [CGColor] = [
            .init(red: 1, green: 0, blue: 0, alpha: 1),
            .init(red: 0, green: 0, blue: 1, alpha: 1)
        ]
        
        let colorMiddle = colors.gradientColor(percent: 50)
        
        let colorMiddleExpectation = CGColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        
        XCTAssertEqual(colorMiddle, colorMiddleExpectation)
    }
    
    func testColorAtMiddleSize() throws {
        let colors: [CGColor] = [
            .init(red: 0, green: 1, blue: 0, alpha: 1),
            .init(red: 1, green: 0, blue: 1, alpha: 1)
        ]
        
        let colorMiddle = colors.gradientColor(at: 2, size: 3)
        
        let colorMiddleExpectation = CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        
        XCTAssertEqual(colorMiddle, colorMiddleExpectation)
    }
    
    func testGradientColors() throws {
        let colors: [CGColor] = [
            .init(red: 0, green: 0, blue: 1, alpha: 1),
            .init(red: 1, green: 0, blue: 0, alpha: 1)
        ]
        let size: CGFloat = 11
        
        let gradientColorsExpectation: [CGColor] = [
            .init(red: 0.0, green: 0, blue: 1.0, alpha: 1),
            .init(red: 0.1, green: 0, blue: 0.9, alpha: 1),
            .init(red: 0.2, green: 0, blue: 0.8, alpha: 1),
            .init(red: 0.3, green: 0, blue: 0.7, alpha: 1),
            .init(red: 0.4, green: 0, blue: 0.6, alpha: 1),
            .init(red: 0.5, green: 0, blue: 0.5, alpha: 1),
            .init(red: 0.6, green: 0, blue: 0.4, alpha: 1),
            .init(red: 0.7, green: 0, blue: 0.3, alpha: 1),
            .init(red: 0.8, green: 0, blue: 0.2, alpha: 1),
            .init(red: 0.9, green: 0, blue: 0.1, alpha: 1),
            .init(red: 1.0, green: 0, blue: 0.0, alpha: 1)
        ]
        
        let gradientColors = colors.gradientColors(in: size)
        
        XCTAssertEqual(gradientColors.count, gradientColorsExpectation.count)
        
        XCTAssertEqual(gradientColors.first, colors.first)
        XCTAssertEqual(gradientColors.last, colors.last)
        
        let accuracy = 0.000000001
        gradientColors.enumerated().forEach { index, color in
            color.components?.enumerated().forEach({ componentIndex, value in
                let valueExpectation = gradientColorsExpectation[index].components![componentIndex]
                XCTAssertEqual(value, valueExpectation, accuracy: accuracy)
            })
        }
    }

}
