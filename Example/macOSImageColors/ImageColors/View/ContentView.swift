//
//  ContentView.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ImageColorsView(model: ImageColorsModel())
            .frame(minWidth: 800, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImageColorsView(model: ImageColorsModel())
    }
}
