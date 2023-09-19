# DominantColors

A library for extracting color from an image.

- [Features](#features)
- [Installation](#installation)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)

## Features

The DominantColors makes it easy to find the dominant colors of the image. It returns a color palette of the most common colors in the image.

<img width="912" alt="Example1" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/3f973ff9-e3af-47af-89e8-5953898b8673">
<img width="912" alt="Example2" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/1734d1a2-59ee-4bcc-a1cc-3acafa38710c">
<img width="912" alt="Example3" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/b5becc52-f1e7-4a2c-895a-f7c424c276f0">
<img width="912" alt="Example4" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/2a09b613-58e2-4e0b-92ff-3932ea8f0bc4">


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
Use the macOS example [ImageColors](https://github.com/DenDmitriev/DominantColors/tree/main/Example/ImageColors) project included in this repository to find examples of various DominantColors features.

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


