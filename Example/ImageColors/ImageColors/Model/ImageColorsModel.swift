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
    @Published var algorithm: DominantColorAlgorithm
    @Published var formula: DeltaEFormula
    @Published var error: ImageColorsError?
    
    init() {
        let formula = DeltaEFormula.CIE94
        self.formula = formula
        self.algorithm = .iterative(formula: formula)
    }
    
    func fetchColors(
        imageURL: URL?,
        algorithm: DominantColorAlgorithm? = nil,
        formula: DeltaEFormula? = nil,
        flags: [DominantColors.Flag] = []
    ) async {
        guard let imageURL else { return }
        
        do {
            let data = try Data(contentsOf: imageURL)
            let nsImage = NSImage(data: data)
            
            guard let cgImage = nsImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
            
            let cgColors = try DominantColors.dominantColors(image: cgImage, algorithm: algorithm ?? self.algorithm, flags: flags)
            let colors = cgColors.map { Color(cgColor: $0) }
            
            DispatchQueue.main.async {
                self.colors = colors
            }
        } catch let error {
            DispatchQueue.main.async {
                self.error = ImageColorsError.map(error: error)
            }
        }
    }
}
