//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import Foundation

public enum DominantColorAlgorithm {
    
    /// Finds the dominant colors of an image by iterating, grouping and sorting its pixels.
    case iterative(formula: DeltaEFormula)
    
    /// Finds the dominant colors of an image by using using a k-means clustering algorithm.
    case kMeansClustering
    
    /// Finds the dominant colors of an image by using using a area average algorithm.
    case areaAverage(count: UInt8)
}
