//
//  RGB.swift
//  
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import CoreImage

struct RGB: Hashable {
    let R: CGFloat
    let G: CGFloat
    let B: CGFloat
}

extension CGColor {
    // MARK: - Public
    
    /// The red (R) channel of the RGB color space as a value from 0.0 to 1.0.
    public var red: CGFloat {
        CIColor(cgColor: self).red
    }
    
    /// The green (G) channel of the RGB color space as a value from 0.0 to 1.0.
    public var green: CGFloat {
        CIColor(cgColor: self).green
    }
    
    /// The blue (B) channel of the RGB color space as a value from 0.0 to 1.0.
    public var blue: CGFloat {
        CIColor(cgColor: self).blue
    }
    
    /// The alpha (a) channel of the RGBa color space as a value from 0.0 to 1.0.
//    public var alpha: CGFloat {
//        CIColor(cgColor: self).alpha
//    }
    
    // MARK: Internal
    
    var red255: CGFloat {
        self.red * 255.0
    }
    
    var green255: CGFloat {
        self.green * 255.0
    }
    
    var blue255: CGFloat {
        self.blue * 255.0
    }
    
    var rgb: RGB {
        return RGB(R: self.red, G: self.green, B: self.blue)
    }
}
