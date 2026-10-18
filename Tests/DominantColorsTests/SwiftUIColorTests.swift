//
//  SwiftUIColorTests.swift
//
//
//  Created by Jonathan Rajya on 18.10.2026.
//

import SwiftUI
import XCTest
@testable import DominantColors

final class SwiftUIColorTests: XCTestCase {
    
    /// A 40x40 image, half red and half blue.
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
        context.setFillColor(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 20, height: 40))
        context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1))
        context.fill(CGRect(x: 20, y: 0, width: 20, height: 40))
        return try XCTUnwrap(context.makeImage())
    }
    
    func testSwiftUIColorsMatchCGColors() throws {
        let image = try makeImage()
        
        let cgColors = try DominantColors.dominantColors(image: image, quality: .best, maxCount: 2)
        let colors = try DominantColors.dominantSwiftUIColors(image: image, quality: .best, maxCount: 2)
        
        XCTAssertEqual(colors.count, cgColors.count)
        XCTAssertEqual(colors.count, 2)
    }
}
