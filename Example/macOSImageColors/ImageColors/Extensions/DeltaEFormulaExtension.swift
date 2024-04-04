//
//  DeltaEFormulaExtension.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import Foundation
import DominantColors

extension DeltaEFormula {
    var title: String {
        switch self {
        case .euclidean:
            return "Euclidean"
        case .CIE76:
            return "CIE76"
        case .CIE94:
            return "CIE94"
        case .CIEDE2000:
            return "CIEDE2000"
        case .CMC:
            return "CMC"
        }
    }
}
