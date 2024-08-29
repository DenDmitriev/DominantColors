//
//  AverageColor+UIColor.swift
//  
//
//  Created by Saffet Emin Reisoğlu on 8/29/24.
//

#if os(iOS)
import UIKit

@available(iOS 2.0, *)
extension AverageColor {
    
    public static func averageColor(uiImage: UIImage) throws -> UIColor {
        guard let cgImage = uiImage.cgImage else { throw ImageColorError.cgImageFailure }
        return .init(cgColor: try averageColor(image: cgImage))
    }
}
#endif
