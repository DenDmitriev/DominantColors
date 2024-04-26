//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import Foundation

public enum DominantColorAlgorithm: Identifiable, Hashable {

    /// Finds the dominant colors of an image by iterating, grouping and sorting its pixels.
    case iterative(formula: DeltaEFormula)
    
    /// Finds the dominant colors of an image by using using a k-means clustering algorithm.
    case kMeansClustering
    
    /// Finds the dominant colors of an image by using using a area average algorithm.
    case areaAverage(count: UInt8)
    
    var algorithm: String {
        switch self {
        case .iterative:
            "Iterative"
        case .kMeansClustering:
            "K-means Clustering"
        case .areaAverage:
            "Area Average"
        }
    }
    
    public var id: String {
        self.algorithm
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.algorithm)
    }
}
