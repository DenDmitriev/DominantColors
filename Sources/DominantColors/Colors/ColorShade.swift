//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 30.04.2024.
//

import CoreGraphics.CGColor

/// Classification of colors by shades
///
/// Dividing colors into shades along the color wheel using the coordinates of angle, saturation and brightness
public enum ColorShade: CaseIterable {
    // Classification by lightness
    case white
    case black
    case dark
    case bright
    
    // Classification by saturation
    case gray
    
    // Classification by HUE
    case red
    case redOrange
    case orange
    case yellowOrange
    case yellow
    case yellowGreen
    case green
    case blueGreen
    case blue
    case blueViolet
    case violet
    case redViolet
    
    // Classification by HUE, saturation, lightness
    case brown
    case pink
    
    case unknown
    
    public var superShade: Self {
        switch self {
        case .redOrange:
            return .red
        case .yellowOrange:
            return .orange
        case .yellowGreen:
            return .green
        case .blueGreen:
            return .green
        case .blueViolet:
            return .violet
        case .redViolet:
            return .violet
        default:
            return self
        }
    }
    
    public init(cgColor: CGColor) {
        let hue = cgColor.hue
        let lightness = cgColor.lightness
        let saturation = cgColor.saturation
        self = Self.getColor(hue: hue, saturation: saturation, lightness: lightness)
    }
    
    public init(hsl: HSL) {
        let hue = hsl.hue
        let lightness = hsl.lightness
        let saturation = hsl.saturation
        self = Self.getColor(hue: hue, saturation: saturation, lightness: lightness)
    }
    
    private static func getColor(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> Self {
        /// Check for black or white
        switch lightness {
        case _ where Self.whiteLightnessRange ~= lightness:
            return .white
        case _ where Self.blackLightnessRange ~= lightness:
            return .black
        case _ where Self.darkLightnessRange ~= lightness:
            return .dark
        default:
            break
        }
        
        /// Check for gray
        switch saturation {
        case _ where Self.graySaturationRange ~= saturation:
            return .gray
        default:
            break
        }
        
        /// Check for shade by hue, saturation and lightness
        if Self.isBrown(hue: hue, saturation: saturation, lightness: lightness) {
            return .brown
        }
        
        if Self.isPink(hue: hue, saturation: saturation, lightness: lightness) {
            return .pink
        }
        
        /// Check color shade by hue circle
        switch hue {
        case _ where Self.redHUEStartRang ~= hue || Self.redHUEEndRang ~= hue:
            if darkRedLightnessRang ~= lightness && darkRedSaturationRang ~= saturation {
                return .dark
            } else if brightRedLightnessRang ~= lightness && brightRedSaturationRang ~= saturation  {
                return .bright
            } else {
                return .red
            }
        case _ where Self.redOrangeHUERang ~= hue:
            if darkRedOrangeLightnessRang ~= lightness && darkRedOrangeSaturationRang ~= saturation {
                return .dark
            } else if brightRedOrangeLightnessRang ~= lightness && brightRedOrangeSaturationRang ~= saturation  {
                return .bright
            } else {
                return .redOrange
            }
        case _ where Self.orangeHUERang ~= hue:
            if darkOrangeLightnessRang ~= lightness && darkOrangeSaturationRang ~= saturation {
                return .dark
            } else if brightOrangeLightnessRang ~= lightness && brightOrangeSaturationRang ~= saturation  {
                return .bright
            } else {
                return .orange
            }
        case _ where Self.yellowOrangeHUERang ~= hue:
            if darkYellowOrangeLightnessRang ~= lightness && darkYellowOrangeSaturationRang ~= saturation {
                return .dark
            } else if brightYellowOrangeLightnessRang ~= lightness && brightYellowOrangeSaturationRang ~= saturation  {
                return .bright
            } else {
                return .yellowOrange
            }
        case _ where Self.yellowHUERang ~= hue:
            if darkYellowLightnessRang ~= lightness && darkYellowSaturationRang ~= saturation {
                return .dark
            } else if brightYellowLightnessRang ~= lightness && brightYellowSaturationRang ~= saturation  {
                return .bright
            } else {
                return .yellow
            }
        case _ where Self.yellowGreenHUERang ~= hue:
            if darkYellowGreenLightnessRang ~= lightness && darkYellowGreenSaturationRang ~= saturation {
                return .dark
            } else if brightYellowGreenLightnessRang ~= lightness && brightYellowGreenSaturationRang ~= saturation  {
                return .bright
            } else {
                return .yellowGreen
            }
        case _ where Self.greenHUERang ~= hue:
            if darkGreenLightnessRang ~= lightness && darkGreenSaturationRang ~= saturation {
                return .dark
            } else if brightGreenLightnessRang ~= lightness && brightGreenSaturationRang ~= saturation  {
                return .bright
            } else {
                return .green
            }
        case _ where Self.blueGreenHUERang ~= hue:
            if darkBlueGreenLightnessRang ~= lightness && darkBlueGreenSaturationRang ~= saturation {
                return .dark
            } else if brightBlueGreenLightnessRang ~= lightness && brightBlueGreenSaturationRang ~= saturation  {
                return .bright
            } else {
                return .blueGreen
            }
        case _ where Self.blueHUERang ~= hue:
            if darkBlueLightnessRang ~= lightness && darkBlueSaturationRang ~= saturation {
                return .dark
            } else if brightBlueLightnessRang ~= lightness && brightBlueSaturationRang ~= saturation  {
                return .bright
            } else {
                return .blue
            }
        case _ where Self.blueVioletHUERang ~= hue:
            if darkBlueVioletLightnessRang ~= lightness && darkBlueVioletSaturationRang ~= saturation {
                return .dark
            } else if brightBlueVioletLightnessRang ~= lightness && brightBlueVioletSaturationRang ~= saturation  {
                return .bright
            } else {
                return .blueViolet
            }
        case _ where Self.violetHUERang ~= hue:
            if darkVioletLightnessRang ~= lightness && darkVioletSaturationRang ~= saturation {
                return .dark
            } else if brightVioletLightnessRang ~= lightness && brightVioletSaturationRang ~= saturation  {
                return .bright
            } else {
                return .violet
            }
        case _ where Self.redVioletHUERang ~= hue:
            if darkRedVioletLightnessRang ~= lightness && darkRedVioletSaturationRang ~= saturation {
                return .dark
            } else if brightRedVioletLightnessRang ~= lightness && brightRedVioletSaturationRang ~= saturation  {
                return .bright
            } else {
                return .redViolet
            }
        default:
            return .unknown
        }
    }
    
    // MARK: - Hue Calculation Options
    // MARK: White and black options
    private static let whiteLightnessRange: ClosedRange<CGFloat> = 90...100
    private static let blackLightnessRange: ClosedRange<CGFloat> = 0...10
    
    // MARK: Dark options
    private static let darkLightnessRange: ClosedRange<CGFloat> = 0...20
    
    // MARK: Gray options
    private static let graySaturationRange: ClosedRange<CGFloat> = 0...15
    
    // MARK: Colors hue ranges
    private static let redHUEStartRang: Range<CGFloat> =     0..<11
    private static let redHUEEndRang: ClosedRange<CGFloat> = 340...360
    private static let redOrangeHUERang: Range<CGFloat> =    11..<20
    private static let orangeHUERang: Range<CGFloat> =       20..<35
    private static let yellowOrangeHUERang: Range<CGFloat> = 35..<50
    private static let yellowHUERang: Range<CGFloat> =       50..<70
    private static let yellowGreenHUERang: Range<CGFloat> =  70..<90
    private static let greenHUERang: Range<CGFloat> =        90..<160
    private static let blueGreenHUERang: Range<CGFloat> =    160..<190
    private static let blueHUERang: Range<CGFloat> =         190..<251
    private static let blueVioletHUERang: Range<CGFloat> =   251..<260
    private static let violetHUERang: Range<CGFloat> =       260..<300
    private static let redVioletHUERang: Range<CGFloat> =    300..<340
    
    // MARK: Dark red ranges
    private static let darkRedSaturationRang: ClosedRange<CGFloat> = 0...25
    private static let darkRedLightnessRang: ClosedRange<CGFloat> = 0...30
    // MARK: Bright red ranges
    private static let brightRedSaturationRang: ClosedRange<CGFloat> = 0...100
    private static let brightRedLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark red-orange ranges
    private static let darkRedOrangeSaturationRang: ClosedRange<CGFloat> = 0...25
    private static let darkRedOrangeLightnessRang: ClosedRange<CGFloat> = 0...30
    // MARK: Bright red-orange ranges
    private static let brightRedOrangeSaturationRang: ClosedRange<CGFloat> = 0...100
    private static let brightRedOrangeLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark orange ranges
    private static let darkOrangeSaturationRang: ClosedRange<CGFloat> = 0...25
    private static let darkOrangeLightnessRang: ClosedRange<CGFloat> = 0...30
    // MARK: Bright orange ranges
    private static let brightOrangeSaturationRang: ClosedRange<CGFloat> = 0...100
    private static let brightOrangeLightnessRang: ClosedRange<CGFloat> = 75...100
    
    // MARK: Dark yellow-orange ranges
    private static let darkYellowOrangeSaturationRang: ClosedRange<CGFloat> = 0...35
    private static let darkYellowOrangeLightnessRang: ClosedRange<CGFloat> = 0...30
    // MARK: Bright yellow-orange ranges
    private static let brightYellowOrangeSaturationRang: ClosedRange<CGFloat> = 0...35
    private static let brightYellowOrangeLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark yellow ranges
    private static let darkYellowSaturationRang: ClosedRange<CGFloat> = 0...20
    private static let darkYellowLightnessRang: ClosedRange<CGFloat> = 0...25
    // MARK: Bright yellow ranges
    private static let brightYellowSaturationRang: ClosedRange<CGFloat> = 0...35
    private static let brightYellowLightnessRang: ClosedRange<CGFloat> = 75...100
    
    // MARK: Dark yellow-green ranges
    private static let darkYellowGreenSaturationRang: ClosedRange<CGFloat> = 0...20
    private static let darkYellowGreenLightnessRang: ClosedRange<CGFloat> = 0...25
    // MARK: Bright yellow-green ranges
    private static let brightYellowGreenSaturationRang: ClosedRange<CGFloat> = 0...35
    private static let brightYellowGreenLightnessRang: ClosedRange<CGFloat> = 75...100
    
    // MARK: Dark green ranges
    private static let darkGreenSaturationRang: ClosedRange<CGFloat> = 0...15
    private static let darkGreenLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright green ranges
    private static let brightGreenSaturationRang: ClosedRange<CGFloat> = 0...35
    private static let brightGreenLightnessRang: ClosedRange<CGFloat> = 75...100
    
    // MARK: Dark blue-green ranges
    private static let darkBlueGreenSaturationRang: ClosedRange<CGFloat> = 0...20
    private static let darkBlueGreenLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright blue-green ranges
    private static let brightBlueGreenSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let brightBlueGreenLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark blue ranges
    private static let darkBlueSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let darkBlueLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright blue ranges
    private static let brightBlueSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let brightBlueLightnessRang: ClosedRange<CGFloat> = 75...100
    
    // MARK: Dark blue-violet ranges
    private static let darkBlueVioletSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let darkBlueVioletLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright blue-violet ranges
    private static let brightBlueVioletSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let brightBlueVioletLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark violet ranges
    private static let darkVioletSaturationRang: ClosedRange<CGFloat> = 0...25
    private static let darkVioletLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright violet ranges
    private static let brightVioletSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let brightVioletLightnessRang: ClosedRange<CGFloat> = 80...100
    
    // MARK: Dark red-violet ranges
    private static let darkRedVioletSaturationRang: ClosedRange<CGFloat> = 0...25
    private static let darkRedVioletLightnessRang: ClosedRange<CGFloat> = 0...20
    // MARK: Bright red-violet ranges
    private static let brightRedVioletSaturationRang: ClosedRange<CGFloat> = 0...30
    private static let brightRedVioletLightnessRang: ClosedRange<CGFloat> = 80...100
    
    
    // MARK: Brown color ranges
    private static let brownHUERang: Range<CGFloat> = 0..<40
    private static let brownSaturationRang: Range<CGFloat> = 10..<100
    private static let brownLightnessRang: Range<CGFloat> = 10..<75
    
    // MARK: Pink color ranges
    private static let pinkHUERangStartCircle: ClosedRange<CGFloat> = 0...15
    private static let pinkHUERangEndCircle: ClosedRange<CGFloat> = 320...360
    private static let pinkSaturationRang: ClosedRange<CGFloat> = 10...100
    private static let pinkLightnessRang: Range<CGFloat> = 60..<80
    
    
    // MARK: - Calculate shades
    private static func isBrown(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> Bool {
        brownHUERang ~= hue &&
        brownSaturationRang ~= saturation &&
        brownLightnessRang ~= lightness
    }
    
    private static func isPink(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> Bool {
        (pinkHUERangStartCircle ~= hue || pinkHUERangEndCircle ~= hue) &&
        pinkSaturationRang ~= saturation &&
        pinkLightnessRang ~= lightness
    }
}

extension ColorShade: CustomStringConvertible {
    
    public var description: String {
        "\(self.title)"
    }
    
    public var title: String {
        switch self {
        case .red:
            "red"
        case .redOrange:
            "red-orange"
        case .orange:
            "orange"
        case .yellowOrange:
            "yellow-orange"
        case .yellow:
            "yellow"
        case .yellowGreen:
            "yellow-green"
        case .green:
            "green"
        case .blueGreen:
            "blue-green"
        case .blue:
            "blue"
        case .blueViolet:
            "blue-violet"
        case .violet:
            "violet"
        case .redViolet:
            "red-violet"
        case .white:
            "white"
        case .black:
            "black"
        case .gray:
            "gray"
        case .unknown:
            "unknown"
        case .brown:
            "brown"
        case .pink:
            "pink"
        case .dark:
            "dark"
        case .bright:
            "bright"
        }
    }
}

extension ColorShade: Comparable {
    
}
