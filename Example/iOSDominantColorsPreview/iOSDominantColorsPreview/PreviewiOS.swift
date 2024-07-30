//
//  PreviewiOS.swift
//
//
//  Created by Denis Dmitriev on 02.05.2024.
//
#if os(iOS)
import SwiftUI
import DominantColors

@available(iOS 15.0, *)
struct Preview: View {
    
    private static let images = ["LittleMissSunshine", "bladerunner056", "TheLifeAquaticWithSteveZissou", "ComeTogether", "blackwhite", "bladerunner042"]
    @State private var selection: Int = .zero
    @State private var uiImage: UIImage?
    @State private var cgImage: CGImage?
    @State private var cgImageSize: CGSize = .zero
    @State private var colors = [Color]()
    @State private var contrastColors: ContrastColors?
    @State private var sorting: DominantColors.Sort = .frequency
    @State private var algorithm: DeltaEFormula = .CIE76
    @State private var pureBlack: Bool = true
    @State private var pureWhite: Bool = true
    @State private var pureGray: Bool = false
    @State private var deltaColor: Int = 10
    @State private var countColors: Int = 6
    
    var body: some View {
        VStack {
            // Image group
            VStack(spacing: 0) {
                ImageSlider(imageNames: Self.images, selection: $selection)
                    .frame(height: 400)
                    .background(.gray)
                    .onAppear {
                        loadImage(Self.images[selection])
                    }
                    .onChange(of: selection) { newSelection in
                        loadImage(Self.images[newSelection])
                    }
                
                Title(title: "Title", subtitle: "Subtitle", contrastColors: $contrastColors)
                    .frame(height: 100)
                
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
                .background(.secondary)
                .background(.gray)
                .onChange(of: uiImage) { newImage in
                    refreshColors(from: newImage)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }
            
            // Setting group
            ScrollView {
                VStack {
                    VStack(spacing: 16) {
                        HStack {
                            HStack {
                                Text("Method")
                                Picker("Method", selection: $algorithm) {
                                    ForEach(DeltaEFormula.allCases) { algorithm in
                                        Text(algorithm.method)
                                            .tag(algorithm)
                                    }
                                }
                                .onChange(of: algorithm) { _ in
                                    refreshColors()
                                }
                            }
                            
                            HStack{
                                Text("Sorting")
                                Picker("Sorting", selection: $sorting) {
                                    ForEach(DominantColors.Sort.allCases) { sorting in
                                        Text(sorting.name)
                                            .tag(sorting)
                                    }
                                }
                                .onChange(of: sorting) { _ in
                                    refreshColors()
                                }
                            }
                            
                            Spacer()
                        }
                        .pickerStyle(.menu)
                        
                        HStack(spacing: 16) {
                            HStack {
                                Text("Color Delta")
                                TextField("Delta", value: $deltaColor, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 64)
                            }
                            
                            HStack {
                                Text("Color Count")
                                TextField("Delta", value: $countColors, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 64)
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        OptionToggle(isEnable: $pureBlack, color: .black)
                        OptionToggle(isEnable: $pureGray, color: .gray)
                        OptionToggle(isEnable: $pureWhite, color: .white)
                        Spacer()
                    }
                    .onChange(of: [pureBlack, pureGray, pureWhite]) { _ in
                        refreshColors()
                    }
                }
                .padding()
            }
            
            Button(action: refreshColors, label: {
                Label("Refresh", systemImage: "arrow.clockwise.circle.fill")
            })
            .buttonStyle(.borderedProminent)
            .disabled(colors.isEmpty)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var placeholderImage: some View {
        Text("No image")
            .foregroundStyle(.gray)
            .frame(height: 300)
    }
    
    private func refreshColors() {
        if let uiImage {
            refreshColors(from: uiImage)
        }
    }
    
    private func loadImage(_ name: String) {
        let uiImage = UIImage(named: name, in: Bundle.main, with: nil)
        
        DispatchQueue.main.async {
            self.uiImage = uiImage
        }
    }
    
    private func refreshColors(from uiImage: UIImage?) {
        guard let uiImage else { return }
        
        colors.removeAll()
        
        var flags = [DominantColors.Options]()
        if pureBlack { flags.append(.excludeBlack) }
        if pureWhite { flags.append(.excludeWhite) }
        if pureGray { flags.append(.excludeGray) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let uiColors = try DominantColors.dominantColors(
                    uiImage: uiImage,
                    quality: .fair,
                    algorithm: algorithm,
                    maxCount: countColors,
                    options: flags,
                    sorting: sorting,
                    deltaColors: CGFloat(deltaColor),
                    timeLog: true
                )
                DispatchQueue.main.async {
                    self.colors = uiColors.map({ Color(uiColor: $0) })
                }
                
                let contrastColors = ContrastColors(colors: uiColors.map({ $0.cgColor }))
                DispatchQueue.main.async {
                    self.contrastColors = contrastColors
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

@available(iOS 15.0, *)
struct OptionToggle: View {
    @Binding var isEnable: Bool
    let color: Color
    var body: some View {
        Circle()
            .stroke(.gray, lineWidth: 3)
            .background(Circle().fill(color))
            .frame(width: 33)
            .overlay {
                if isEnable {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.black))
                        .foregroundStyle(.tint)
                }
            }
            .onTapGesture {
                withAnimation {
                    isEnable.toggle()
                }
            }
    }
}

@available(iOS 15.0, *)
struct Title: View {
    @State var title: String
    @State var subtitle: String
    @Binding var contrastColors: ContrastColors?
    
    var body: some View {
        VStack {
            if let contrastColors {
                VStack {
                    Text(title)
                        .font(.largeTitle)
                        .foregroundStyle(Color(cgColor: contrastColors.primary))
                    
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(Color(cgColor: contrastColors.secondary ?? CGColor(gray: 0, alpha: 0)))
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(cgColor: contrastColors.background))
            } else {
                Color.gray
                    .overlay {
                        Text("No colors")
                    }
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
                if let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
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
