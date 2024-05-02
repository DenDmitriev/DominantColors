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
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE76:
            let differenceValue = sqrt(pow(color.L - self.L, 2) + pow(color.a - self.a, 2) + pow(color.b - self.b, 2))
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE94:
            let differenceValue = CGColor.deltaECIE94(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIEDE2000:
            let differenceValue = CGColor.deltaCIEDE2000(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CMC:
            let differenceValue = CGColor.deltaCMC(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
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
    
    ///http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CMC.html
    private static func deltaCMC(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let lab1 = Lab(L: lhs.L, a: lhs.a, b: lhs.b)
        let lab2 = Lab(L: rhs.L, a: rhs.a, b: rhs.b)

        let c1 = sqrt(pow(lab1.a, 2) + pow(lab1.b, 2))
        let c2 = sqrt(pow(lab2.a, 2) + pow(lab2.b, 2))
        let deltaC = c1 - c2

        let deltaA = lab1.a - lab2.a
        let deltaB = lab1.b - lab2.b

        let deltaH = sqrt(pow(deltaA, 2) + pow(deltaB, 2) - pow(deltaC, 2))

        let deltaL = lab1.L - lab2.L

        let sL = lab1.L < 16 ? 0.511 : (0.040975 * lab1.L) / (1 + 0.01765 * lab1.L)

        let sC = (0.0638 * c1) / (1 + 0.0131 * c1) + 0.638

        let h = lab1.a == 0 ? 0 : atan(lab1.b / lab1.a)
        let h1 = h >= 0 ? h : h + 360

        let t = 164...345 ~= h1 ? 0.56 + abs(0.2 * cos(h1 + 168)) : 0.36 + abs(0.4 * cos(h1 + 35))

        let f = sqrt(pow(c1, 4) / (pow(c1, 4) + 1900))

        let sH = sC * (f * t + 1 - f)

        let p1 = pow((deltaL / sL), 2)
        let p2 = pow((deltaC / sC), 2)
        let p3 = pow((deltaH / sH), 2)

        let deltaE = sqrt(p1 + p2 + p3) / 2 // because result from 0...200 / 100 = 0...100
        
        return deltaE
    }
}
