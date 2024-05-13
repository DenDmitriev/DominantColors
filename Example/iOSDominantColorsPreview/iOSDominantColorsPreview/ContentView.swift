//
//  ContentView.swift
//  iOSDominantColorsPreview
//
//  Created by Denis Dmitriev on 01.05.2024.
//

import SwiftUI
import PhotosUI
import DominantColors

struct ContentView: View {
    
    @State private var uiImage: UIImage?
    @State private var colors = [Color]()
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageURL: URL?
    @State private var showingAlert = false
    @State private var showingSettings = false
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var showUI = true
    
    @State private var contrastColors: ContrastColors?
    
    // Settings
    @State private var formula: DeltaEFormula = .CIE94
    @State private var countColor: Int = 6
    @State private var quality: DominantColorQuality = .fair
    
    // Options
    @State private var removeBlack: Bool = true
    @State private var removeWhite: Bool = false
    @State private var removeGray: Bool = false
    
    // Order
    @State private var sorting: DominantColors.Sort = .frequency
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showUI.toggle()
                        }
                } else {
                    placeholderImage
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if showUI {
                    TitleView(title: "Title", subtitle: "Subtitle", contrastColors: $contrastColors)
                        .padding(.bottom, 140)
                }
            }
            .overlay(alignment: .bottom, content: {
                HStack(spacing: .zero) {
                    if !colors.isEmpty {
                        ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                            Rectangle()
                                .fill(color)
                        }
                    } else if uiImage != nil {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .onChange(of: uiImage) { newImage in
                    if let newImage {
                        refreshColors(from: newImage)
                    }
                }
                .frame(height: verticalSizeClass == .compact ? 50 : 100)
            })
            .ignoresSafeArea()
            .toolbar {
                if showUI {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAlert.toggle()
                        } label: {
                            Image(systemName: "link.circle.fill")
                        }
                        .alert("Paste image URL", isPresented: $showingAlert) {
                            TextField("URL image", value: $imageURL, format: .url)
                                .padding()
                            
                            Button("OK", action: {
                                if let imageURL {
                                    Task {
                                        await loadImage(.network(url: imageURL))
                                    }
                                }
                            })
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Image(systemName: "photo.stack.fill")
                        }
                        .onChange(of: pickerItem) { pickerItem in
                            Task {
                                await loadImage(.gallery(pickerItem: pickerItem))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button("Setting", systemImage: "gearshape.fill") {
                            showingSettings.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings, onDismiss: {
            if let uiImage {
                refreshColors(from: uiImage)
            }
        }, content: {
            ColorSettingsView(
                formula: $formula,
                countColor: $countColor,
                quality: $quality,
                removeBlack: $removeBlack,
                removeWhite: $removeWhite,
                removeGray: $removeGray,
                sorting: $sorting
            )
            .presentationDetents([.fraction(0.4)])
        })
        .task {
            await loadImage(.asset(name: "ComeTogether"))
        }
    }
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
}

extension ContentView {
    enum LoadImageType {
        case gallery(pickerItem: PhotosPickerItem?), network(url: URL), asset(name: String)
    }
    
    private func loadImage(_ type: LoadImageType) async {
        let resultImage: UIImage
        switch type {
        case .gallery(let pickerItem):
            guard let data = try? await pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data)
            else { return }
            
            resultImage = uiImage
        case .network(let url):
            guard let result = try? await URLSession.shared.data(from: url),
                  let uiImage = UIImage(data: result.0)
            else { return }
            
            resultImage = uiImage
        case .asset(let name):
            guard let uiImage = UIImage(named: name) else { return }
            
            resultImage = uiImage
        }
        
        DispatchQueue.main.async {
            self.uiImage = resultImage
        }
    }
    
    private func refreshColors(from uiImage: UIImage){
        colors.removeAll()
        
        Task {
            var options: [DominantColors.Options] = []
            if removeBlack { options.append(.excludeBlack) }
            if removeWhite { options.append(.excludeWhite) }
            if removeGray { options.append(.excludeGray) }
            
            guard let uiColors = try? DominantColors.dominantColors(
                uiImage: uiImage,
                quality: quality,
                algorithm: formula,
                maxCount: countColor,
                options: options,
                sorting: sorting
            )
            else { return }

            DispatchQueue.main.async {
                self.colors = uiColors.map({ Color(uiColor: $0) })
            }
            
            let contrastColors = ContrastColors(colors: uiColors.map({ $0.cgColor }))
            
            DispatchQueue.main.async {
                self.contrastColors = contrastColors
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
