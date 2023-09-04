//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

extension CGColor {
    
    public enum ColorDifferenceResult: Comparable {
        
        /// There is no difference between the two colors.
        case indentical(CGFloat)
        
        /// The difference between the two colors is not perceptible by human eye.
        case similar(CGFloat)
        
        /// The difference between the two colors is perceptible through close observation.
        case close(CGFloat)
        
        /// The difference between the two colors is perceptible at a glance.
        case near(CGFloat)
        
        /// The two colors are different, but not opposite.
        case different(CGFloat)
        
        /// The two colors are more opposite than similar.
        case far(CGFloat)
        
        init(value: CGFloat) {
            if value == 0 {
                self = .indentical(value)
            } else if value <= 1.0 {
                self = .similar(value)
            } else if value <= 2.0 {
                self = .close(value)
            } else if value <= 10.0 {
                self = .near(value)
            } else if value <= 50.0 {
                self = .different(value)
            } else {
                self = .far(value)
            }
        }
        
        var associatedValue: CGFloat {
            switch self {
            case .indentical(let value),
                 .similar(let value),
                 .close(let value),
                 .near(let value),
                 .different(let value),
                 .far(let value):
                 return value
            }
        }
        
        public static func < (lhs: CGColor.ColorDifferenceResult, rhs: CGColor.ColorDifferenceResult) -> Bool {
            return lhs.associatedValue < rhs.associatedValue
        }
                
    }
    
    /// The different algorithms for comparing colors.
    /// @see https://en.wikipedia.org/wiki/Color_difference
    public enum DeltaEFormula {
        /// The euclidean algorithm is the simplest and fastest one, but will yield results that are unexpected to the human eye. Especially in the green range.
        /// It simply calculates the euclidean distance in the RGB color space.
        case euclidean
        
        /// The `CIE76`algorithm is fast and yields acceptable results in most scenario.
        case CIE76
        
        /// The `CIE94` algorithm is an improvement to the `CIE76`, especially for the saturated regions. It's marginally slower than `CIE76`.
        case CIE94
        
        /// The `CIEDE2000` algorithm is the most precise algorithm to compare colors.
        /// It is considerably slower than its predecessors.
        case CIEDE2000
    }
    
    /// Computes the difference between the passed in `CGColor` instance.
    ///
    /// - Parameters:
    ///   - color: The color to compare this instance to.
    ///   - formula: The algorithm to use to make the comparaison.
    /// - Returns: The different between the passed in `CGColor` instance and this instance.
    public func difference(from color: CGColor, using formula: DeltaEFormula = .CIE94) -> ColorDifferenceResult {
        switch formula {
        case .euclidean:
            let differenceValue = sqrt(pow(self.red255 - color.red255, 2) + pow(self.green255 - color.green255, 2) + pow(self.blue255 - color.blue255, 2))
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE76:
            let differenceValue = sqrt(pow(color.L - self.L, 2) + pow(color.a - self.a, 2) + pow(color.b - self.b, 2))
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE94:
            let differenceValue = CGColor.deltaECIE94(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIEDE2000:
            let differenceValue = CGColor.deltaCIEDE2000(lhs: self, rhs: color)
        }
    }
    
    private static func deltaECIE94(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let kL: CGFloat = 1.0
        let kC: CGFloat = 1.0
        let kH: CGFloat = 1.0
        let k1: CGFloat = 0.045
        let k2: CGFloat = 0.015
        let sL: CGFloat = 1.0
        
        let c1 = sqrt(pow(lhs.a, 2) + pow(lhs.b, 2))
        let sC = 1 + k1 * c1
        let sH = 1 + k2 * c1
        
        let deltaL = lhs.L - rhs.L
        let deltaA = lhs.a - rhs.a
        let deltaB = lhs.b - rhs.b
                
        let c2 = sqrt(pow(rhs.a, 2) + pow(rhs.b, 2))
        let deltaCab = c1 - c2

        let deltaHab = sqrt(pow(deltaA, 2) + pow(deltaB, 2) - pow(deltaCab, 2))
        
        let p1 = pow(deltaL / (kL * sL), 2)
        let p2 = pow(deltaCab / (kC * sC), 2)
        let p3 = pow(deltaHab / (kH * sH), 2)
        
        let deltaE = sqrt(p1 + p2 + p3)
        
        return deltaE
    }
    
    private static func deltaCIEDE2000(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let kL: CGFloat = 1.0
        let kC: CGFloat = 1.0
        let kH: CGFloat = 1.0
        let k1: CGFloat = 0.045
        let k2: CGFloat = 0.015
        let sL: CGFloat = 1.0
        
        let c1 = sqrt(pow(lhs.a, 2) + pow(lhs.b, 2))
        let sC = 1 + k1 * c1
        let sH = 1 + k2 * c1
        
        let deltaL = lhs.L - rhs.L
        let deltaA = lhs.a - rhs.a
        let deltaB = lhs.b - rhs.b
                
        let c2 = sqrt(pow(rhs.a, 2) + pow(rhs.b, 2))
        let deltaCab = c1 - c2

        let deltaHab = sqrt(pow(deltaA, 2) + pow(deltaB, 2) - pow(deltaCab, 2))
        
        let pi = CGFloat.pi
        let cAverage = (c1 + c2) / 2
        let cHelp = sqrt(pow(cAverage, 7) / (pow(cAverage, 7) + pow(25, 7)))
        
        let b1 = lhs.b
        let a1 = lhs.a
        let a1Trait = a1 + (a1 / 2) * (1 - (1 / 2) * cHelp)
        
        let b2 = rhs.b
        let a2 = rhs.a
        let a2Trait = a1 + (a2 / 2) * (1 - (1 / 2) * cHelp)
        
        let h1Shift = atan(b1 / a1Trait).truncatingRemainder(dividingBy: 2 * pi)
        let h2Shift = atan(b2 / a2Trait).truncatingRemainder(dividingBy: 2 * pi)
        
        let deltaHAverage = (h1Shift - h2Shift) > pi
        let extraAngle = deltaHAverage ? 2 * pi : .zero
        let hAverage = (h1Shift + h2Shift + extraAngle) / 2
        let valueRtHelp = 5 * pi / 36
        let expValue = pow((hAverage - 11 * valueRtHelp) / valueRtHelp, 2)
        
        let rT = -2 * cHelp * sin((pi / 6) * exp(-expValue))
        
        let p1 = pow(deltaL / (kL * sL), 2)
        let p2 = pow(deltaCab / (kC * sC), 2)
        let p3 = pow(deltaHab / (kH * sH), 2)
        let p4 = rT * (deltaCab * deltaHab) / (sC * sH)
        
        let deltaE = sqrt(p1 + p2 + p3 + p4)
        
        return deltaE
    }
}
