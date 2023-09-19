//
//  ColorPaletteView.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import SwiftUI
import DominantColors

struct ColorPaletteView: View {
    
    @State var colors: [Color]
    @EnvironmentObject var model: ImageColorsModel
    @State var showHex: Bool
    
    init(
        showHex: Bool,
        colors: [Color] = [
            .red,
            .orange,
            .yellow,
            .green,
            .cyan,
            .blue,
            .purple
        ]
    ) {
        self.showHex = showHex
        self.colors = colors
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(colors, id: \.self) { color in
                Rectangle()
                    .fill(color)
                    .overlay {
                        if showHex {
                            Text(hex(for: color))
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(4)
                        }
                    }
            }
        }
        .onReceive(model.$colors) { colors in
            if !colors.isEmpty {
                self.colors = colors
            }
        }
    }
    
    private func hex(for color: Color) -> String {
        let hexColor = Hex(cgColor: color.cgColor ?? .black)
        return hexColor.hex
    }
}

struct ColorPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPaletteView(showHex: true)
            .environmentObject(ImageColorsModel())
            .previewLayout(.fixed(width: 800, height: 50))
    }
}
