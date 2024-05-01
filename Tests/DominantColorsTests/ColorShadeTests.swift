//
//  ColorShadeTests.swift
//
//
//  Created by Denis Dmitriev on 30.04.2024.
//

import XCTest
@testable import DominantColors

final class ColorShadeTests: XCTestCase {

    func testRedShades() throws {
        let name = NSImage.Name("Red_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 24)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .red }).count, 13)
        XCTAssertEqual(colorCircles.filter({ $0 == .pink }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .brown }).count, 4)
        XCTAssertEqual(colorCircles.filter({ $0 == .white }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .bright }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .black }).count, 1)
    }
    
    func testOrangeShades() throws {
        let name = NSImage.Name("Orange_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 25)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .orange }).count, 5)
        XCTAssertEqual(colorCircles.filter({ $0 == .brown }).count, 10)
        XCTAssertEqual(colorCircles.filter({ $0 == .yellowOrange }).count, 4)
        XCTAssertEqual(colorCircles.filter({ $0 == .white }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .bright }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .redOrange }).count, 1)
    }
    
    func testYellowShades() throws {
        let name = NSImage.Name("Yellow_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 9)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .yellow }).count, 5)
        XCTAssertEqual(colorCircles.filter({ $0 == .brown }).count, 1)
        XCTAssertEqual(colorCircles.filter({ $0 == .yellowOrange }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .white }).count, 1)
    }
    
    func testGreenShades() throws {
        let name = NSImage.Name("Green_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 24)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .green }).count, 18)
        XCTAssertEqual(colorCircles.filter({ $0 == .dark }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .gray }).count, 1)
        XCTAssertEqual(colorCircles.filter({ $0 == .white }).count, 2)
    }
    
    func testBlueShades() throws {
        let name = NSImage.Name("Blue_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 9)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        print(cgColors.map({ $0.hue }), terminator: ", ")
        
        XCTAssertEqual(colorCircles.filter({ $0 == .blue }).count, 9)
    }
    
    func testVioletShades() throws {
        let name = NSImage.Name("Violet_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 21)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .violet }).count, 17)
        XCTAssertEqual(colorCircles.filter({ $0 == .blueViolet }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .black }).count, 1)
    }
    
    func testBrownShades() throws {
        let name = NSImage.Name("Brown_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 9)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .brown }).count, 8)
        XCTAssertEqual(colorCircles.filter({ $0 == .dark }).count, 1)
    }
    
    func testPinkShades() throws {
        let name = NSImage.Name("Pink_Shades")
        let nsImage = Bundle.module.image(forResource: name)
        let cgImage = nsImage!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        let cgColors = try getCGColors(cgImage: cgImage)
        
        XCTAssertEqual(cgColors.count, 9)
        
        let colorCircles = cgColors.map({ ColorShade(cgColor: $0) })
        
        XCTAssertEqual(colorCircles.filter({ $0 == .pink }).count, 2)
        XCTAssertEqual(colorCircles.filter({ $0 == .bright }).count, 3)
        XCTAssertEqual(colorCircles.filter({ $0 == .brown }).count, 1)
        XCTAssertEqual(colorCircles.filter({ $0 == .redViolet }).count, 1)
        XCTAssertEqual(colorCircles.filter({ $0 == .white }).count, 2)
    }
    
    private func getCGColors(cgImage: CGImage) throws -> Set<CGColor> {
        var colorsSet = Set<RGB255>()
        
        guard let cfData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(cfData)
        else { throw ImageColorError.cgImageDataFailure }
        
        for yCoordonate in 0 ..< cgImage.height {
            for xCoordonate in 0 ..< cgImage.width {
                let index = (cgImage.width * yCoordonate + xCoordonate) * 4
                
                // Let's make sure there is enough alpha 150 / 250 = 60%.
                let alpha = data[index + 3]
                guard alpha > 150 else {
                    continue
                }
                
                let red = data[index + 0]
                let green = data[index + 1]
                let blue = data[index + 2]
                
                let pixelColor = RGB255(red: red, green: green, blue: blue)
                
                colorsSet.insert(pixelColor)
            }
        }
        
        if let colorSpace = cgImage.colorSpace {
            var cgColors = Set<CGColor>()
            for color in colorsSet {
                let cgColor = color.cgColor(colorSpace: colorSpace)
                cgColors.insert(cgColor)
            }
            return cgColors
        } else {
            XCTFail("Can't get color space.")
            return []
        }
    }

}
