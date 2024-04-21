//
//  Preview.swift
//
//
//  Created by Denis Dmitriev on 21.04.2024.
//

import SwiftUI

@available(macOS 14.0, *)
struct Preview: View {
    
    @State private var nsImage: NSImage?
    @State private var colors = [Color]()
    
    var body: some View {
        VStack(spacing: 0) {
            if let nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderImage
            }
            
            HStack(spacing: .zero) {
                if !colors.isEmpty, nsImage != nil {
                    ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                        Rectangle()
                            .fill(color)
                    }
                } else {
                    if nsImage != nil {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .onChange(of: nsImage) { newImage in
                if let newImage {
                    refreshColors(from: newImage)
                }
            }
            .frame(height: 100)
            
        }
        .onAppear {
            loadImage("WaterLife1")
        }
    }
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
    
    private func loadImage(_ name: String) {
        let name = NSImage.Name(name)
        let nsImage = Bundle.module.image(forResource: name)
        
        DispatchQueue.main.async {
            self.nsImage = nsImage
        }
    }
    
    private func refreshColors(from nsImage: NSImage) {
        colors.removeAll()
        
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        do {
            let cgColors = try DominantColors.dominantColors(image: cgImage, dominationColors: 8, flags: [.excludeBlack, .excludeWhite])
            DispatchQueue.main.async {
                self.colors = cgColors.map({ Color(cgColor: $0) })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

@available(macOS 14.0, *)
#Preview {
    Preview()
        .frame(width: 640, height: 460)
}
