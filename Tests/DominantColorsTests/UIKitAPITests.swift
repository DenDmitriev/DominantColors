//
//  UIKitAPITests.swift
//
//
//  Created by Jonathan Rajya on 18.10.2026.
//

#if canImport(UIKit)
import UIKit
import XCTest
@testable import DominantColors

/// The UIKit overloads are available on every platform that has UIKit: iOS, tvOS and visionOS.
final class UIKitAPITests: XCTestCase {
    
    /// A 40x40 image, half red and half blue.
    private func makeImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 20, height: 40))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 20, y: 0, width: 20, height: 40))
        }
    }
    
    func testDominantUIColors() throws {
        let colors = try DominantColors.dominantColors(uiImage: makeImage(), quality: .best, maxCount: 2)
        XCTAssertEqual(colors.count, 2)
    }
    
    func testUIImageDominantColors() throws {
        let colors = try makeImage().dominantColors(max: 2)
        XCTAssertEqual(colors.count, 2)
    }
    
    func testAverageUIColor() throws {
        _ = try AverageColor.averageColor(uiImage: makeImage())
    }
    
    func testBlackAndWhiteConstants() {
        XCTAssertEqual(CGColor.black, CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(CGColor.white, CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    }
}
#endif
