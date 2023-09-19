//
//  ImageColorsModel.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import SwiftUI
import DominantColors

class ImageColorsModel: ObservableObject {
    @Published var colors = [Color]()
    @Published var error: ImageColorsError?
    @Published var isProgress: Bool = false
    
    func fetchColors(
        imageURL: URL?,
        algorithm: DominantColorAlgorithm,
        formula: DeltaEFormula? = nil,
        flags: [DominantColors.Flag] = []
    ) async {
        guard let imageURL else { return }
        
        DispatchQueue.main.async {
            self.isProgress = true
        }
        
        do {
            let data = try Data(contentsOf: imageURL)
            let nsImage = NSImage(data: data)
            
            guard let cgImage = nsImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
            
            var algorithm = algorithm
            if let formula = formula {
                algorithm = .iterative(formula: formula)
            }
            
            print(algorithm, flags)
            
            let cgColors = try DominantColors.dominantColors(image: cgImage, algorithm: algorithm, flags: flags)
            let colors = cgColors.map { Color(cgColor: $0) }
            
            DispatchQueue.main.async {
                self.colors = colors
                self.isProgress = false
            }
        } catch let error {
            DispatchQueue.main.async {
                self.error = ImageColorsError.map(error: error)
            }
        }
    }
}
