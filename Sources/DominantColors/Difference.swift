//
//  Difference.swift
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
    /// In color science, color difference or color distance is the separation between two colors. 
    /// This metric allows quantified examination of a notion that formerly could only be described with adjectives.
    /// [Color difference](https://en.wikipedia.org/wiki/Color_difference)
    ///
    /// - Parameters:
    ///   - color: The color to compare this instance to.
    ///   - formula: The algorithm to use to make the comparison.
    /// - Returns: The different between the passed in `CGColor` instance and this instance.
    public func difference(from color: CGColor, using formula: DeltaEFormula = .CIE94) -> ColorDifferenceResult {
        switch formula {
        case .euclidean:
            let differenceValue = CGColor.deltaEuclidean(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrAwayFromZero, precision: 1000)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE76:
            let differenceValue = CGColor.deltaECIE76(lhs: self, rhs: color)
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
    
    /// The color difference, or ΔE, between two colors according to the Euclidean formulas.
    ///
    /// https://en.wikipedia.org/wiki/Color_difference
    private static func deltaEuclidean(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let deltaE = sqrt(pow(lhs.red255 - rhs.red255, 2) + pow(lhs.green255 - rhs.green255, 2) + pow(lhs.blue255 - rhs.blue255, 2))
        return deltaE
    }
    
    /// The color difference, or ΔE, between two colors according to the 1976 CIE formulas.
    ///
    /// [Formulas](http://www.brucelindbloom.com/index.html?ColorCalculator.html).
    private static func deltaECIE76(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let deltaE = sqrt(pow(rhs.L - lhs.L, 2) + pow(rhs.a - lhs.a, 2) + pow(rhs.b - lhs.b, 2))
        return deltaE
    }
    
    /// The color difference, or ΔE, between two colors according to the 1994 CIE formulas.
    ///
    /// [Formulas](http://www.brucelindbloom.com/Eqn_DeltaE_CIE94.html)
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
    
    /// The color difference, or ΔE, between two colors according to the 2000 CIE formulas.
    ///
    /// [Formulas](http://www.brucelindbloom.com/Eqn_DeltaE_CIE2000.html)
    private static func deltaCIEDE2000(lhs: CGColor, rhs: CGColor) -> CGFloat {
        /*
         * "For these and all other numerical/graphical 􏰀delta E00 values
         * reported in this article, we set the parametric weighting factors
         * to unity(i.e., k_L = k_C = k_H = 1.0)." (Page 27).
         */
        let k_L = 1.0, k_C = 1.0, k_H = 1.0
        let deg360InRad = deg2rad(360.0)
        let deg180InRad = deg2rad(180.0)
        let pow25To7 = 6103515625.0 /* pow(25, 7) */
        
        /*
         * Step 1
         */
        /* Equation 2 */
        let C1 = sqrt((lhs.a * lhs.a) + (lhs.b * lhs.b))
        let C2 = sqrt((rhs.a * rhs.a) + (rhs.b * rhs.b))
        /* Equation 3 */
        let barC = (C1 + C2) / 2.0
        /* Equation 4 */
        let powBarCTo7 = pow(barC, 7)
        let G = 0.5 * (1 - sqrt(powBarCTo7 / (powBarCTo7 + pow25To7)))
        /* Equation 5 */
        let a1Prime = (1.0 + G) * lhs.a
        let a2Prime = (1.0 + G) * rhs.a
        /* Equation 6 */
        let CPrime1 = sqrt((a1Prime * a1Prime) + (lhs.b * lhs.b))
        let CPrime2 = sqrt((a2Prime * a2Prime) + (rhs.b * rhs.b))
        /* Equation 7 */
        var hPrime1: CGFloat
        if lhs.b == 0 && a1Prime == 0 {
            hPrime1 = 0.0
        } else {
            hPrime1 = atan2(lhs.b, a1Prime)
            /*
             * This must be converted to a hue angle in degrees between 0
             * and 360 by addition of 2􏰏 to negative hue angles.
             */
            if hPrime1 < 0 {
                hPrime1 += deg360InRad
            }
        }
        var hPrime2: CGFloat
        if rhs.b == 0 && a2Prime == 0 {
            hPrime2 = 0.0
        } else {
            hPrime2 = atan2(rhs.b, a2Prime)
            /*
             * This must be converted to a hue angle in degrees between 0
             * and 360 by addition of 2􏰏 to negative hue angles.
             */
            if hPrime2 < 0 {
                hPrime2 += deg360InRad
            }
        }
        
        /*
         * Step 2
         */
        /* Equation 8 */
        let deltaLPrime = rhs.L - lhs.L
        /* Equation 9 */
        let deltaCPrime = CPrime2 - CPrime1
        /* Equation 10 */
        var deltahPrime: CGFloat
        let CPrimeProduct = CPrime1 * CPrime2
        if CPrimeProduct == 0 {
            deltahPrime = 0
        } else {
            /* Avoid the fabs() call */
            deltahPrime = hPrime2 - hPrime1
            if deltahPrime < -deg180InRad {
                deltahPrime += deg360InRad
            } else if deltahPrime > deg180InRad {
                deltahPrime -= deg360InRad
            }
        }
        /* Equation 11 */
        let deltaHPrime = 2.0 * sqrt(CPrimeProduct) *  sin(deltahPrime / 2.0)
        
        /*
         * Step 3
         */
        /* Equation 12 */
        let barLPrime = (lhs.L + rhs.L) / 2.0
        /* Equation 13 */
        let barCPrime = (CPrime1 + CPrime2) / 2.0
        /* Equation 14 */
        var barhPrime = hPrime1 + hPrime2
        let hPrimeSum = hPrime1 + hPrime2
        if CPrime1 * CPrime2 == 0 {
            barhPrime = hPrimeSum
        } else {
            if fabs(hPrime1 - hPrime2) <= deg180InRad {
                barhPrime = hPrimeSum / 2.0
            } else {
                if hPrimeSum < deg360InRad {
                    barhPrime = (hPrimeSum + deg360InRad) / 2.0
                } else {
                    barhPrime = (hPrimeSum - deg360InRad) / 2.0
                }
            }
        }
        /* Equation 15 */
        let T = 1.0 - (0.17 * cos(barhPrime - deg2rad(30.0))) + (0.24 * cos(2.0 * barhPrime)) + (0.32 * cos((3.0 * barhPrime) + deg2rad(6.0))) - (0.20 * cos((4.0 * barhPrime) - deg2rad(63.0)))
        /* Equation 16 */
        let deltaTheta = deg2rad(30.0) * exp(-pow((barhPrime - deg2rad(275.0)) / deg2rad(25.0), 2.0))
        /* Equation 17 */
        let R_C = 2.0 * sqrt(pow(barCPrime, 7.0) / (pow(barCPrime, 7.0) + pow25To7))
        /* Equation 18 */
        let S_L = 1 + ((0.015 * pow(barLPrime - 50.0, 2.0)) / sqrt(20 + pow(barLPrime - 50.0, 2.0)))
        /* Equation 19 */
        let S_C = 1 + (0.045 * barCPrime)
        /* Equation 20 */
        let S_H = 1 + (0.015 * barCPrime * T)
        /* Equation 21 */
        let R_T = (-sin(2.0 * deltaTheta)) * R_C
        
        /* Equation 22 */
        let deltaE = sqrt(pow(deltaLPrime / (k_L * S_L), 2.0) + pow(deltaCPrime / (k_C * S_C), 2.0) + pow(deltaHPrime / (k_H * S_H), 2.0) + (R_T * (deltaCPrime / (k_C * S_C)) * (deltaHPrime / (k_H * S_H))))
        
        return deltaE
    }
    
    /// The color difference, or ΔE, between two colors according to the CMC formulas.
    ///
    /// [Formulas](http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CMC.html)
    private static func deltaCMC(lhs: CGColor, rhs: CGColor) -> CGFloat {
        let l = 1.0
        let c = 1.0
        
        let lab1 = Lab(L: lhs.L, a: lhs.a, b: lhs.b)
        let lab2 = Lab(L: rhs.L, a: rhs.a, b: rhs.b)

        let dA = lab1.a - lab2.a
        
        let dB = lab1.b - lab2.b

        let C1 = sqrt(pow(lab1.a, 2) + pow(lab1.b, 2))
        let C2 = sqrt(pow(lab2.a, 2) + pow(lab2.b, 2))
        let dC = C1 - C2
        
        let dH = sqrt(pow(dA, 2) + pow(dB, 2) - pow(dC, 2))

        let dL = lab1.L - lab2.L

        let sL: CGFloat
        if lab1.L < 16 {
            sL = 0.511
        } else {
            sL = (0.040975 * lab1.L) / (1 + 0.01765 * lab1.L)
        }

        let sC = (0.0638 * C1) / (1 + 0.0131 * C1) + 0.638

        var h1 = lab1.a == 0 ? 0 : rad2deg(atan2(lab1.b, lab1.a))
        if h1 < 0 {
            h1 += 360
        }
        
        var h2 = lab2.a == 0 ? 0 : rad2deg(atan2(lab2.b, lab2.a))
        if h2 < 0 {
            h2 += 360
        }

        let T: CGFloat
        if 164...345 ~= h1 {
            T = 0.56 + abs(0.2 * cos(deg2rad(h1 + 168)))
        } else {
            T = 0.36 + abs(0.4 * cos(deg2rad(h1 + 35)))
        }
        
        let C1pow4 = pow(C1, 4)
        let F = sqrt(C1pow4 / (C1pow4 + 1900))

        let sH = sC * (F * T + 1 - F)

        let p1 = pow((dL / (l * sL)), 2)
        let p2 = pow((dC / (c * sC)), 2)
        let p3 = pow((dH / sH), 2)
        
        let deltaE = sqrt(p1 + p2 + p3)
        
        return deltaE
    }
    
    private static func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    private static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}
