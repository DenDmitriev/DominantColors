//
//  ContentView.swift
//  iOSDemoDominationColor
//
//  Created by Denis Dmitriev on 04.04.2024.
//

import SwiftUI
import PhotosUI
import DominantColors

struct ContentView: View {
    
    @State private var cgImage: CGImage?
    @State private var colors = [Color]()
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageURL: URL?
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            
            if let cgImage {
                Image(uiImage: UIImage(cgImage: cgImage))
                    .resizable()
                    .scaledToFit()
            } else {
                placeholderImage
            }
            
            HStack(spacing: .zero) {
                if !colors.isEmpty, cgImage != nil {
                    ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                        Rectangle()
                            .fill(color)
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .onChange(of: cgImage) { newImage in
                if let newImage {
                    refreshColors(from: newImage)
                }
            }
            .frame(height: 100)
            
            Spacer()
        }
        .background(.black)
        .overlay(alignment: .bottom, content: {
            HStack(spacing: 16) {
                Button {
                    showingAlert.toggle()
                } label: {
                    buttonLabel("Link")
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
                
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    buttonLabel("Gallery")
                }
                .onChange(of: pickerItem) { pickerItem in
                    Task {
                        await loadImage(.gallery(pickerItem: pickerItem))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        })
        .ignoresSafeArea()
        .task {
            await loadImage(.asset(name: "demoImage"))
        }
    }
}

extension ContentView {
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
    
    private func buttonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.title3, weight: .bold))
            .foregroundStyle(.regularMaterial)
            .frame(maxWidth: .infinity)
    }
    
    enum LoadImageType {
        case gallery(pickerItem: PhotosPickerItem?), network(url: URL), asset(name: String)
    }
    
    private func loadImage(_ type: LoadImageType) async {
        let resultImage: CGImage
        switch type {
        case .gallery(let pickerItem):
            guard let data = try? await pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data),
                  let cgImage = uiImage.cgImage
            else { return }
            
            resultImage = cgImage
        case .network(let url):
            guard let result = try? await URLSession.shared.data(from: url),
                  let cgImage = UIImage(data: result.0)?.cgImage
            else { return }
            
            resultImage = cgImage
        case .asset(let name):
            guard let uiImage = UIImage(named: name),
                  let cgImage = uiImage.cgImage
            else { return }
            
            resultImage = cgImage
        }
        
        DispatchQueue.main.async {
            cgImage = resultImage
        }
    }
    
    private func refreshColors(from cgImage: CGImage){
        colors.removeAll()
        Task {
            guard let cgColors = try? DominantColors.dominantColors(image: cgImage, maxCount: 8, options: [.excludeBlack, .excludeWhite])
            else { return }
            
            
            DispatchQueue.main.async {
                self.colors = cgColors.map({ Color(cgColor: $0) })
            }
        }
    }
}

#Preview {
    ContentView()
}
