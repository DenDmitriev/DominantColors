//
//  TitleView.swift
//  iOSDominantColorsPreview
//
//  Created by Denis Dmitriev on 13.05.2024.
//

import SwiftUI
import DominantColors

struct TitleView: View {
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
                .background(Color(cgColor: contrastColors.background))
            } else {
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack {
        TitleView(title: "Title", subtitle: "Subtitle", contrastColors: .constant(ContrastColors(colors: [.black, .white, .init(gray: 0.5, alpha: 1)])))
        
        TitleView(title: "Title", subtitle: "Subtitle", contrastColors: .constant(nil))
    }
}
