//
//  ColorSettingsView.swift
//  iOSDominantColorsPreview
//
//  Created by Denis Dmitriev on 11.05.2024.
//

import SwiftUI
import DominantColors

struct ColorSettingsView: View {
    
    @Environment(\.dismiss) var dissmis
    
    // Settings
    @Binding var formula: DeltaEFormula
    @Binding var countColor: Int
    @Binding var quality: DominantColorQuality
    
    // Options
    @Binding var removeBlack: Bool
    @Binding var removeWhite: Bool
    @Binding var removeGray: Bool
    
    // Order
    @Binding var sorting: DominantColors.Sort
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Button {
                    dissmis()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(4)
            }
            .padding(.top, 8)
            .padding(8)
            
            List {
                Section {
                    HStack {
                        Text("Number of colors")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Count", value: $countColor, format: .number)
                            .keyboardType(.numberPad)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(.primary)
                                    .frame(height: 0.5)
                            }
                            .frame(width: 40)
                        Image(systemName: "number")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Color Difference") {
                    Picker("ΔE Formula", selection: $formula) {
                        ForEach(DeltaEFormula.allCases) {
                            Text($0.method).tag($0)
                        }
                    }
                    
                    Picker("Quality", selection: $quality) {
                        ForEach(DominantColorQuality.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                    
                    Picker("Sorting", selection: $sorting) {
                        ForEach(DominantColors.Sort.allCases) {
                            Text($0.name).tag($0)
                        }
                    }
                }
                
                Section("Options") {
                    Toggle("Remove black colors", isOn: $removeBlack)
                    Toggle("Remove gray colors", isOn: $removeGray)
                    Toggle("Remove white colors", isOn: $removeWhite)
                }
            }
        }
    }
}

#Preview {
    ColorSettingsView(
        formula: .constant(.CIE76),
        countColor: .constant(6),
        quality: .constant(.fair),
        removeBlack: .constant(false),
        removeWhite: .constant(false),
        removeGray: .constant(false),
        sorting: .constant(.frequency)
    )
    .preferredColorScheme(.dark)
}
