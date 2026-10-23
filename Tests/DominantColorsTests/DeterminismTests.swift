//
//  DeterminismTests.swift
//
//
//  Created by Jonathan Rajya on 18.10.2026.
//

import XCTest
@testable import DominantColors

final class DeterminismTests: XCTestCase {
    
    private func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> CGColor {
        CGColor(srgbRed: red, green: green, blue: blue, alpha: 1)
    }
    
    /// Colors with equal values must come out in the same order whatever order they went in,
    /// otherwise the order depends on how sets and dictionaries happened to enumerate them.
    func testSortingTiesDoesNotDependOnInputOrder() {
        let colors = [color(0, 0, 1), color(1, 0, 0), color(0, 1, 0), color(0.5, 0.5, 0.5)]
        let frequencies = colors.map { ColorFrequency(color: $0, count: 1) }
        
        let expected = frequencies.sortedDescending(by: { $0.frequency }).map(\.color)
        for permutation in [frequencies, frequencies.reversed(), Array(frequencies[2...] + frequencies[..<2])] {
            XCTAssertEqual(permutation.sortedDescending(by: { $0.frequency }).map(\.color), expected)
            XCTAssertEqual(permutation.sortedAscending(by: { $0.frequency }).map(\.color), expected)
        }
    }
    
    func testSortingStillOrdersByValueFirst() {
        let low = ColorFrequency(color: color(1, 0, 0), count: 1)
        let high = ColorFrequency(color: color(0, 0, 1), count: 5)
        
        XCTAssertEqual([low, high].sortedDescending(by: { $0.frequency }).map(\.frequency), [5, 1])
        XCTAssertEqual([high, low].sortedAscending(by: { $0.frequency }).map(\.frequency), [1, 5])
    }
    
    func testHashDoesNotDependOnFrequency() {
        let frequency = ColorFrequency(color: color(1, 0, 0), count: 1)
        let before = frequency.hashValue
        frequency.frequency = 100
        XCTAssertEqual(frequency.hashValue, before)
    }
    
    /// Three similar reds and one blue, each a quarter of the image.
    private func makeImage() throws -> CGImage {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try XCTUnwrap(CGContext(
            data: nil,
            width: 40,
            height: 40,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        let columns: [CGColor] = [color(1, 0, 0), color(252 / 255, 3 / 255, 0), color(250 / 255, 0, 3 / 255), color(0, 0, 1)]
        for (index, column) in columns.enumerated() {
            context.setFillColor(column)
            context.fill(CGRect(x: index * 10, y: 0, width: 10, height: 40))
        }
        return try XCTUnwrap(context.makeImage())
    }
    
    /// When similar colors are merged, the merged color must count all of their pixels.
    func testMergedColorsKeepTheirPixelCount() throws {
        let frequencies = try DominantColors.dominantColorFrequencies(image: makeImage(), quality: .best, formula: .CIE94, maxCount: 2)
        
        XCTAssertEqual(frequencies.count, 2)
        let red = try XCTUnwrap(frequencies.first)
        XCTAssertEqual(red.frequency, 0.75, accuracy: 0.02)
        XCTAssertEqual(red.color.red, 1, accuracy: 0.05)
    }
}
