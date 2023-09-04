//
//  File.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreGraphics

extension CGFloat {
    
    func rounded(_ rule: FloatingPointRoundingRule, precision: Int) -> CGFloat {
        return (self * CGFloat(precision)).rounded(rule) / CGFloat(precision)
    }
    
}
