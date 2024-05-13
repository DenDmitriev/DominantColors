# DominantColors

A library for extracting color from an image. 
*Сurrent version 1.1.7*

- [Features](#features)
- [How to use](#how-to-use)
- [Installation](#installation)
- [Example](#example)
- [How the algorithm works](#how-the-algorithm-works)
- [Contributing](#contributing)
- [License](#license)

## Features

The DominantColors makes it easy to find the dominant colors of the image. It returns a color palette of the most common colors in the image.

![LittleMissSunshine Strip](https://github.com/DenDmitriev/DominantColors/assets/65191747/8cf56022-fe73-4682-aeb1-aaf96124fbbb)

![ComeTogether Strip](https://github.com/DenDmitriev/DominantColors/assets/65191747/581e2065-f0c2-4b73-9dec-0acefb4e7b7d)

![The_Weeknd_-_Starboy Strip](https://github.com/DenDmitriev/DominantColors/assets/65191747/d056842e-ef5c-423d-b164-2f3b82872da6)


## How to use
### Standard settings
A quick way to get colors from an image where the image type is `CGImage`, `UIImage` or `NSImage`:
```swift
let dominantColors = try? image.dominantColors(max: 6) // Array of UIColor, NSColor or CGColor
```
If you need more settings, then call the method directly from the library according to the standard settings:
```swift
// Get the CGColors according to the standard settings:
let cgColors = try? DominantColors.dominantColors(image: cgImage, maxCount: 6)

// Get the UIColors according to the standard settings
let uiColors = try? DominantColors.dominantColors(uiImage: uiImage, maxCount: 6)

// Get the NSColors according to the standard settings:
let nsColors = try? DominantColors.dominantColors(nsImage: nsImage, maxCount: 6)

// Get the `Color.Resolved` according to the standard settings:
let colorsResolved =  try? DominantColors.dominantColorsResolved(image: cgImage)
```
## Custom settings
**Next examples are given for `CGColor`, but this is also true for `UIColor` and `NSColor`**

### Algorithm settings
Get colors by selecting algorithm. Extract colors by specifying the [color difference formula](https://en.wikipedia.org/wiki/Color_difference):
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, algorithm: .CIE76)
```
If you need more accurate results, then there is maximum quality (the default is `fair`):
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, quality: .best, algorithm: .CIE76)
```
To quickly extract colors, use:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, quality: .fair)
```
In this case, a pixelization algorithm is used for the original image.

### Options settings
Get colors with options:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, options: [.excludeBlack, .excludeGray, .excludeWhite])
```

### Sorting settings
For the desired sequence and colors, specify the sorting type:
```swift
let cgColors = try? DominantColors.dominantColors(image: cgImage, maxCount: 6, sorting: .darkness)
```
The default is `frequency`, which sorts colors in descending order of their number of pixels with that color.


### Average colors
Get the average color by dividing the image into segments horizontally:
```swift
let cgColors = try? DominantColors.averageColors(image: cgImage, count: 8)
```

### Cluster colors
Finds the dominant colors of an image by using a k-means clustering algorithm:
```swift
let cgColors = try? DominantColors.kMeansClusteringColors(image: cgImage, quality: .fair, count: 10)
```

## Example
### macOS
- [PreviewMacOS](Sources/DominantColors/Preview/PreviewMacOS.swift) in package,
- App [MacOSPreview](https://github.com/DenDmitriev/DominantColors/tree/main/Example/MacOSPreview) in example folder.

### iOS
- [PreviewiOS](Sources/DominantColors/Preview/PreviewiOS.swift) in package,
- App [iOSDominantColorsPreview](https://github.com/DenDmitriev/DominantColors/tree/main/Example/iOSDominantColorsPreview) in example folder.

## Installation

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding DominantColors as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/DenDmitriev/DominantColors.git", .upToNextMajor(from: "1.1.7"))
]
```

## How the algorithm works
The original image is converted according to the specified quality.
### Low
One color is taken from each generated pixel.
<table>
   <tr>
    <td>Source</td>
    <td>Resize</td>
    <td>Pixellate</td>
  </tr>
  <tr>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/71704fc8-21f6-4c69-846e-7a97b18971af"  alt="1" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/f5743d52-9b9b-4b3d-813b-475de81129da" alt="image_resize_low" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/536f2b89-61a8-465f-93ba-babd8ae1d917" alt="image_pixellate_low" width = 480px></td>
   </tr> 
</table>

### Fair
One color is taken from each generated pixel.
<table>
   <tr>
    <td>Source</td>
    <td>Resize</td>
    <td>Pixellate</td>
  </tr>
  <tr>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/71704fc8-21f6-4c69-846e-7a97b18971af"  alt="1" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/8872282a-ff6d-4447-aa6e-ff176378a9b9" alt="image_resize_low" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/1c729ae5-c3f3-4951-b2c9-d33b2c7ad39c" alt="image_pixellate_low" width = 480px></td>
   </tr> 
</table>

### High
One color is taken from each generated pixel.
<table>
   <tr>
    <td>Source</td>
    <td>Resize</td>
    <td>Pixellate</td>
  </tr>
  <tr>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/71704fc8-21f6-4c69-846e-7a97b18971af"  alt="1" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/881fd8f9-0a78-44c1-9634-83b4d38d4fdf" alt="image_resize_low" width = 480px></td>
    <td><img src="https://github.com/DenDmitriev/DominantColors/assets/65191747/531e544a-5896-4aff-be64-7ad629ae166a" alt="image_pixellate_low" width = 480px></td>
   </tr> 
</table>

### Best
Each pixel color is taken without changing the image.

Next, the colors are sorted by `ColorShade` and color normality is calculated using the number of pixels of the same color and normal saturation and brightness values. After sorting, each shade bin connects the colors by calculating [сolor difference](https://en.wikipedia.org/wiki/Color_difference). This happens cyclically until the required number of flowers is in the basket. The next step is to connect the colors between the baskets in the same way until you have the required number of colors. Well, the result is displayed.

## Contributing

Contribution to the DominantColors is always welcome.
To get information about errors and feature requests, open the [issue](https://github.com/DenDmitriev/DominantColors/issues/new).
To contribute to the codebase, just send a [pull request](https://github.com/DenDmitriev/DominantColors/pulls).


## License

See the [license](https://github.com/DenDmitriev/DominantColors/blob/main/LICENSE).
The library uses the code of the original library [ColorKit](https://github.com/Boris-Em/ColorKit), which is rewritten from Objective-C to Swift and supplemented.


