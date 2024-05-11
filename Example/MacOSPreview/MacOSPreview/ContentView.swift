//
//  ContentView.swift
//  MacOSPreview
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import SwiftUI
import DominantColors

struct ContentView: View {
    private static let images = ["LittleMissSunshine", "BladeRunner2049", "NeonDemon"]
    @State private var selection: String = Self.images.first ?? ""
    @State private var nsImage: NSImage?
    @State private var colors = [Color]()
    @State private var sorting: DominantColors.Sort = .frequency
    @State private var algorithm: DeltaEFormula = .CIE76
    @State private var pureBlack: Bool = true
    @State private var pureWhite: Bool = true
    @State private var pureGray: Bool = true
    @State private var deltaColor: Int = 10
    @State private var countColor: Int = 6
    
    var body: some View {
        VStack {
            // Image group
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(.separator)
                    Group {
                        if let nsImage {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            placeholderImage
                        }
                    }
                    .overlay(alignment: .bottom) {
                        HStack {
                            ForEach(ContentView.images, id: \.self) { nameImage in
                                Circle()
                                    .fill(nameImage == selection ? .blue : .gray)
                                    .frame(width: 5)
                                    .onTapGesture {
                                        selection = nameImage
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(.background)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .onChange(of: selection) { newSelection in
                        loadImage(newSelection)
                    }
                }
                
                HStack(spacing: 3) {
                    if !colors.isEmpty, nsImage != nil {
                        ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                            Rectangle()
                                .fill(color)
                        }
                    } else {
                        if nsImage != nil {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .padding(3)
                .background(.separator)
                .onChange(of: nsImage) { newImage in
                    refreshColors(from: newImage)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }
            
            // Setting group
            VStack {
                HStack(spacing: 16) {
                    Picker("Sorting", selection: $sorting) {
                        ForEach(DominantColors.Sort.allCases) { sorting in
                            Text(sorting.name)
                                .tag(sorting)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 160)
                    .onChange(of: sorting) { _ in
                        refreshColors(from: nsImage)
                    }
                    
                    Picker("Method", selection: $algorithm) {
                        ForEach(DeltaEFormula.allCases) { method in
                            Text(method.method)
                                .tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: algorithm) { _ in
                        refreshColors(from: nsImage)
                    }
                    .frame(maxWidth: 160)
                    
                    HStack {
                        Text("Color Delta")
                        TextField("Delta", value: $deltaColor, format: .number)
                            .frame(width: 40)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 24) {
                    Toggle("Pure black", isOn: $pureBlack)
                        .onChange(of: pureBlack) { _ in
                            refreshColors(from: nsImage)
                        }
                    
                    Toggle("Pure white", isOn: $pureWhite)
                        .onChange(of: pureWhite) { _ in
                            refreshColors(from: nsImage)
                        }
                    
                    Toggle("Pure gray", isOn: $pureGray)
                        .onChange(of: pureGray) { _ in
                            refreshColors(from: nsImage)
                        }
                    
                    HStack {
                        Text("Colors Count")
                        TextField("Colors Count", value: $countColor, format: .number)
                            .frame(width: 40)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            
            HStack {
                Text("Colors count: \(colors.count)")
                
                Spacer()
                
                Button(action: {
                    if let nsImage {
                        refreshColors(from: nsImage)
                    }
                }, label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                })
                .disabled(colors.isEmpty)
            }
            .padding()
        }
        .onAppear {
            loadImage(selection)
        }
    }
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
    
    private func loadImage(_ name: String) {
        let name = NSImage.Name(name)
        let nsImage = Bundle.main.image(forResource: name)
        
        DispatchQueue.main.async {
            self.nsImage = nsImage
        }
    }
    
    private func refreshColors(from nsImage: NSImage?) {
        guard let nsImage else { return }
        
        colors.removeAll()
        
        var flags = [DominantColors.Options]()
        if pureBlack { flags.append(.excludeBlack) }
        if pureWhite { flags.append(.excludeWhite) }
        if pureGray { flags.append(.excludeGray) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgColors = try DominantColors.dominantColors(
                    nsImage: nsImage,
                    quality: .fair,
                    algorithm: algorithm,
                    maxCount: countColor,
                    options: flags,
                    sorting: sorting,
                    deltaColors: CGFloat(deltaColor)
                )
                DispatchQueue.main.async {
                    self.colors = cgColors.map({ Color(nsColor: $0) })
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
