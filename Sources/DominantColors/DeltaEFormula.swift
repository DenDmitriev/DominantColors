//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import Foundation

/// The different algorithms for comparing colors.
/// @see https://en.wikipedia.org/wiki/Color_difference
public enum DeltaEFormula: Int, CaseIterable {
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
    
    /// The `CMC` algorithm is defined a difference measure, based on the L*C*h color model.
    /// The quasimetric has two parameters: lightness (l) and chroma (c), allowing the users to weight the difference based on the ratio of l:c that is deemed appropriate for the application.
    case CMC
}
