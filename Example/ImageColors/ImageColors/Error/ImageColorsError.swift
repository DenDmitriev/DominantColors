//
//  ImageColorsError.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import Foundation

enum ImageColorsError: Error {
    case map(error: Error)
}

extension ImageColorsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .map(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .map(let error):
            if let localizedError = error as? LocalizedError {
                return localizedError.recoverySuggestion
            } else {
                return "Try again"
            }
        }
    }
}
