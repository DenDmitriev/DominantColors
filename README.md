# DominantColors

A library for extracting color from an image. 
*Сurrent version 1.1.3*

- [Features](#features)
- [Installation](#installation)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)

## Features

The DominantColors makes it easy to find the dominant colors of the image. It returns a color palette of the most common colors in the image.

<img width="593" alt="Снимок экрана 2024-05-01 в 22 46 07" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/710961b1-631e-48da-9160-399138a7b581">

<img width="593" alt="Снимок экрана 2024-05-01 в 22 46 13" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/4b13316e-1671-4357-8666-6f21718afde4">

<img width="593" alt="Снимок экрана 2024-05-01 в 22 49 08" src="https://github.com/DenDmitriev/DominantColors/assets/65191747/7cc97436-5b89-4039-a3fe-10909cace40c">



Get the colors according to the standard settings:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, maxCount: 6)
```

Get colors by selecting algorithm. Extract colors by specifying the [color difference formula](https://en.wikipedia.org/wiki/Color_difference):
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, algorithm: .iterative(formula: .CIE76))
```
If you need more accurate results, then there is maximum quality (the default is `fair`):
```swift
let cgColors = try? DominantColors.dominantColors(
                    image: cgImage,
                    quality: .best,
                    algorithm: .iterative(formula: .CIE76))
```
To quickly extract colors, use:
```swift
let cgColors = try? DominantColors.dominantColors(
                    image: cgImage,
                    quality: .fair)
```
In this case, a pixelization algorithm is used for the original image.

Get colors with options:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, options: [.excludeBlack, .excludeGray, .excludeWhite])
```

For the desired sequence and colors, specify the sorting type:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, maxCount: 6, sorting: .darkness)
```
The default is `frequency`, which sorts colors in descending order of their number of pixels with that color.

Get the average color by dividing the image into segments horizontally:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, algorithm: .areaAverage(count: 8))
```

Finds the dominant colors of an image by using a k-means clustering algorithm:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, algorithm: .kMeansClustering)
```

## Example
- macOS
Use the macOS example [macOSImageColors](https://github.com/DenDmitriev/DominantColors/tree/main/Example/macOSImageColors) project included in this repository to find examples of various DominantColors features.

- iOS
Use the iOS example [iOSDemoDominationColor](https://github.com/DenDmitriev/DominantColors/tree/main/Example/iOSDemoDominationColor) for acquaintance.

## Installation

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding DominantColors as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/DenDmitriev/DominantColors.git", .upToNextMajor(from: "1.1.3"))
]
```

## Contributing

Contribution to the DominantColors is always welcome.
To get information about errors and feature requests, open the [issue](https://github.com/DenDmitriev/DominantColors/issues/new).
To contribute to the codebase, just send a [pull request](https://github.com/DenDmitriev/DominantColors/pulls).


## License

See the [license](https://github.com/DenDmitriev/DominantColors/blob/main/LICENSE).
The library uses the code of the original library [ColorKit](https://github.com/Boris-Em/ColorKit), which is rewritten from Objective-C to Swift and supplemented.


