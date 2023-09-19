# DominantColors

A library for extracting color from an image.

- [Features](#features)
- [Installation](#installation)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)

## Features

The DominantColors makes it easy to find the dominant colors of the image. It returns a color palette of the most common colors in the image.

Get the colors according to the standard settings:
```swift
let cgColors = try DominantColors.dominantColors(image: cgImage)
```

Get colors by selecting algorithm. Extract colors by specifying the [color difference formula](https://en.wikipedia.org/wiki/Color_difference):
```swift
let formula: DeltaEFormula = .CIE94
let algorithm: DominantColorAlgorithm = .iterative(formula: formula)

let cgColors = try DominantColors.dominantColors(image: cgImage, algorithm: algorithm)
```

Get colors with options:
```swift
let flags: [DominantColors.Flag] = [.excludeBlack]

let cgColors = try DominantColors.dominantColors(image: cgImage, flags: flags)
```

Get the average color by dividing the image into segments horizontally:
```swift
let count: UInt8 = 8

let cgColors = try DominantColors.dominantColors(image: cgImage, algorithm: .areaAverage(count: count))
```

## Example
Use the macOS example [ImageColors](https://github.com/DenDmitriev/DominantColors/Example/ImageColors) project included in this repository to find examples of various DominantColors features.

## Installation

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding DominantColors as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/DenDmitriev/DominantColors.git", .upToNextMajor(from: "1.0.5"))
]
```

## Contributing

Contribution to the DominantColors is always welcome.
To get information about errors and feature requests, open the [issue](https://github.com/DenDmitriev/DominantColors/issues/new).
To contribute to the codebase, just send a [pull request](https://github.com/DenDmitriev/DominantColors/pulls).


## License

See the [license](https://github.com/DenDmitriev/DominantColors/LICENSE).
The library uses the code of the original library [ColorKit](https://github.com/Boris-Em/ColorKit), which is rewritten from Objective-C to Swift and supplemented.


