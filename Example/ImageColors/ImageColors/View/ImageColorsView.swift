//
//  ImageColorsView.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import SwiftUI
import DominantColors

struct ImageColorsView: View {
    
    @ObservedObject var model: ImageColorsModel
    @State private var imageURL: URL?
    @State private var showFileImporter = false
    @State private var showAlertError = false
    @State private var isFit = true
    @State private var isExcludeBlack = false
    @State private var isExcludeWhite = false
    @State var colorCount: Int = 8
    @State var algorithm: DominantColorAlgorithm = .kMeansClustering
    @State var formula: DeltaEFormula = .CIE76
    @State var isProgress: Bool = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VSplitView {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: isFit ? .fit : .fill)
                    } placeholder: {
                        Image(systemName: "photo")
                            .symbolVariant(.fill)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                Rectangle()
                                    .fill(.quaternary)
                            )
                    }
                    .frame(maxHeight: .infinity)
                    
                    ColorPaletteView(showHex: false)
                        .frame(minHeight: geometry.size.height / 24, idealHeight: geometry.size.height / 16, maxHeight: geometry.size.height / 8)
                        .environmentObject(model)
                        .overlay {
                            if isProgress {
                                ZStack {
                                    Rectangle()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(.ultraThinMaterial)
                                    
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                
                            }
                        }
                }
                .background(.black)
            }
            
            VStack {
                GroupBox("Algorithm") {
                    HStack(spacing: 16) {
                        Picker(selection: $algorithm) {
                            ForEach(algorithms, id: \.self) { algorithm in
                                Text(algorithm.title)
                            }
                        } label: {
                            Text("Algorithm")
                        }
                        .frame(width: 200)
                        
                        Picker(selection: $formula) {
                            ForEach(DeltaEFormula.allCases, id: \.self) { formula in
                                Text(formula.title)
                            }
                        } label: {
                            Text("Formula")
                        }
                        .disabled(algorithm != .iterative(formula: formula))
                        .frame(width: 200)

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                }
                
                GroupBox("Flags") {
                    HStack {
                        Toggle("Exclude black", isOn: $isExcludeBlack)
                        Toggle("Exclude white", isOn: $isExcludeWhite)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                }
                .disabled(algorithm != .iterative(formula: formula))
                
                Group {
                    Button("Import image") {
                        showFileImporter.toggle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top)
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            Button(isFit ? "Fill" : "Fit") {
                isFit.toggle()
            }
            .buttonStyle(.plain)
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding()
        }
        .onChange(of: algorithm, perform: { algorithm in
            Task {
                await model.fetchColors(imageURL: imageURL, algorithm: algorithm, formula: formula, flags: createFlags())
            }
        })
        .onChange(of: formula, perform: { formula in
            Task {
                await model.fetchColors(imageURL: imageURL, algorithm: .iterative(formula: formula), flags: createFlags())
            }
        })
        .onChange(of: isExcludeBlack, perform: { isExcludeBlack in
            Task {
                await model.fetchColors(imageURL: imageURL, algorithm: algorithm, formula: formula, flags: createFlags(isExcludeBlack: isExcludeBlack))
            }
        })
        .onChange(of: isExcludeWhite, perform: { isExcludeWhite in
            Task {
                await model.fetchColors(imageURL: imageURL, algorithm: algorithm, formula: formula, flags: createFlags(isExcludeWhite: isExcludeWhite))
            }
        })
        .onReceive(model.$isProgress, perform: { isProgress in
            self.isProgress = isProgress
        })
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image]
        ) { result in
            switch result {
            case .success(let url):
                if url.startAccessingSecurityScopedResource() {
                    self.imageURL = url
                }
                Task {
                    await model.fetchColors(imageURL: imageURL, algorithm: algorithm, flags: createFlags())
                }
            case .failure(let failure):
                print(failure)
            }
        }
        .alert(isPresented: $showAlertError, error: model.error) { _ in
            Button("OK", role: .cancel, action: {})
        } message: { error in
            Text(error.recoverySuggestion ?? "Try again")
        }
    }
    
    private func createFlags(isExcludeBlack: Bool? = nil, isExcludeWhite: Bool? = nil) -> [DominantColors.Flag] {
        var flags = [DominantColors.Flag]()
        if isExcludeBlack ?? self.isExcludeBlack {
            flags.append(.excludeBlack)
        }
        
        if isExcludeWhite ?? self.isExcludeWhite {
            flags.append(.excludeWhite)
        }
        
        return flags
    }
    
    private var algorithms: [DominantColorAlgorithm] {
        [
            .areaAverage(count: UInt8(colorCount)),
            .iterative(formula: formula),
            .kMeansClustering
        ]
    }
}

struct ImageColorsView_Previews: PreviewProvider {
    static var previews: some View {
        ImageColorsView(model: ImageColorsModel())
    }
}
