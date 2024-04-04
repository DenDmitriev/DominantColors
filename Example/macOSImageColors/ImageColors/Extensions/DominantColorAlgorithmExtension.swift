//
//  DominantColorAlgorithmExtension.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import Foundation
import DominantColors

extension DominantColorAlgorithm:  Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public static func == (lhs: DominantColorAlgorithm, rhs: DominantColorAlgorithm) -> Bool {
        lhs.title == rhs.title
    }
    
    var title: String {
        switch self {
        case .areaAverage:
            return "Area average"
        case .iterative:
            return "Iterative"
        case .kMeansClustering:
            return "Means Clustering"
        }
    }
}
