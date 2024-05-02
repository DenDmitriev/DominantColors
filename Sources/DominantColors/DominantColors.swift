//
//  DominantColors.swift
//
//
//  Created by Denis Dmitriev on 03.09.2023.
//

import CoreImage

public class DominantColors {
    /// Enum of additional options for removing flowers.
    public enum Options {
        /// Remove pure black colors
        case excludeBlack
        /// Remove pure white colors
        case excludeWhite
        /// Remove pure gray colors
        case excludeGray
    }
    
    /// Color sorting options.
    public enum Sort: CaseIterable, Identifiable {
        /// Sorting colors from darkness to lightness.
        case darkness
        /// Sorting colors from lightness to darkness.
        case lightness
        /// Sorting colors by frequency in image.
        case frequency
        
        public var name: String {
            switch self {
            case .darkness:
                "Darkness"
            case .lightness:
                "Lightness"
            case .frequency:
                "Frequency"
            }
        }
        
        public var id: String {
            self.name
        }
    }
}
