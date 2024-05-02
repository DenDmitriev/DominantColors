//
//  PreviewiOS.swift
//
//
//  Created by Denis Dmitriev on 02.05.2024.
//
#if os(iOS)
import SwiftUI

@available(iOS 15.0, *)
struct Preview: View {
    
    private static let images = ["LittleMissSunshine", "bladerunner056", "TheLifeAquaticWithSteveZissou", "ComeTogether", "blackwhite", "bladerunner042"]
    @State private var selection: Int = .zero
    @State private var uiImage: UIImage?
    @State private var cgImage: CGImage?
    @State private var cgImageSize: CGSize = .zero
    @State private var colors = [Color]()
    @State private var sorting: DominantColors.Sort = .frequency
    @State private var method: DeltaEFormula = .CIE76
    @State private var pureBlack: Bool = true
    @State private var pureWhite: Bool = true
    @State private var pureGray: Bool = true
    @State private var deltaColor: Int = 10
    
    var body: some View {
        VStack {
            // Image group
            VStack(spacing: 0) {
                ImageSlider(imageNames: Self.images, selection: $selection)
                    .onAppear {
                        loadImage(Self.images[selection])
                    }
                    .onChange(of: selection) { newSelection in
                        loadImage(Self.images[newSelection])
                    }
                
                HStack(spacing: 3) {
                    if !colors.isEmpty, uiImage != nil {
                        ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                            Rectangle()
                                .fill(color)
                        }
                    } else {
                        if uiImage != nil {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .animation(.snappy, value: colors)
                .padding(3)
                .background(.gray)
                .onChange(of: uiImage) { newImage in
                    refreshColors(from: newImage)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }
            
            // Setting group
            VStack {
                VStack(spacing: 16) {
                    HStack{
                        Text("Sorting")
                        Picker("Sorting", selection: $sorting) {
                            ForEach(DominantColors.Sort.allCases) { sorting in
                                Text(sorting.name)
                                    .tag(sorting)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: sorting) { _ in
                            refreshColors(from: uiImage)
                        }
                    }
                    HStack {
                        Text("Method")
                        Picker("Method", selection: $method) {
                            ForEach(DeltaEFormula.allCases) { method in
                                Text(method.method)
                                    .tag(method)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: method) { _ in
                            refreshColors(from: uiImage)
                        }
                    }
                    
                    HStack {
                        Text("Color Delta")
                        TextField("Delta", value: $deltaColor, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 64)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Toggle("Pure black", isOn: $pureBlack)
                        .onChange(of: pureBlack) { _ in
                            refreshColors(from: uiImage)
                        }
                    
                    Toggle("Pure white", isOn: $pureWhite)
                        .onChange(of: pureWhite) { _ in
                            refreshColors(from: uiImage)
                        }
                    
                    Toggle("Pure gray", isOn: $pureGray)
                        .onChange(of: pureGray) { _ in
                            refreshColors(from: uiImage)
                        }
                    
                    Spacer()
                    
                    Text("Colors count: \(colors.count)")
                }
            }
            .padding()
            
            Button(action: {
                if let uiImage {
                    refreshColors(from: uiImage)
                }
            }, label: {
                Label("Refresh", systemImage: "arrow.clockwise.circle.fill")
            })
            .buttonStyle(.borderedProminent)
            .disabled(colors.isEmpty)
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
    
    private func loadImage(_ name: String) {
        let uiImage = UIImage(named: name, in: Bundle.module, with: nil)
        
        DispatchQueue.main.async {
            self.uiImage = uiImage
        }
    }
    
    private func refreshColors(from uiImage: UIImage?) {
        guard let uiImage else { return }
        
        colors.removeAll()
        
        guard let cgImage = uiImage.cgImage else { return }
        
        var flags = [DominantColors.Options]()
        if pureBlack { flags.append(.excludeBlack) }
        if pureWhite { flags.append(.excludeWhite) }
        if pureGray { flags.append(.excludeGray) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgColors = try DominantColors.dominantColors(
                    image: cgImage,
                    quality: .fair,
                    algorithm: .iterative(formula: method),
                    maxCount: 6,
                    options: flags,
                    sorting: sorting,
                    deltaColors: CGFloat(deltaColor),
                    time: false
                )
                DispatchQueue.main.async {
                    self.colors = cgColors.map({ Color(UIColor(cgColor: $0)) })
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
@available(iOS 15.0, *)
struct ImageSlider: View {
    let imageNames: [String]
    @Binding var selection: Int
    @State private var size: CGSize = .zero
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(zip(imageNames.indices, imageNames)), id: \.0) { index, imageName in
                if let uiImage = UIImage(named: imageName, in: Bundle.module, with: nil) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(index)
                }
            }
        }
        .background(.gray)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .readSize(onChange: { size in
            self.size = size
        })
        .overlay(alignment: .bottom, content: {
            HStack(spacing: 5, content: {
                ForEach(imageNames.indices, id: \.self) { index in
                    let opacityFactor = Double(abs(selection - index) - 1)
                    let opacityInactive = 0.2 - (0.05 * opacityFactor)
                    Circle()
                        .fill(.primary)
                        .opacity(index == selection ? 1 : opacityInactive)
                        .frame(height: 6)
                        .onTapGesture {
                            withAnimation {
                                selection = index
                            }
                        }
                }
            })
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.background)
            }
                .frame(height: 18)
                .padding(8)
        })
        .frame(height: size.width)
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

@available(iOS 15.0, *)
#Preview {
    Preview()
}
#endif
