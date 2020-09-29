# VCR

[![Build Status](https://travis-ci.org/aarons22/SwiftVCR.svg?branch=master)](https://travis-ci.org/aarons22/SwiftVCR)
[![Version](https://img.shields.io/cocoapods/v/VCR.svg?style=flat)](https://cocoapods.org/pods/VCR)
[![Platform](https://img.shields.io/cocoapods/p/VCR.svg?style=flat)](https://cocoapods.org/pods/VCR)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

In order to save tapes, you will need to define `VCR_DIR` in your scheme. This should point to the directory where you want tapes to be stored. We normally use this:

|Name|Value|
|:---|:----|
|`VCR_DIR`|`$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/VCRTapes`|

<!-- TODO: Insert screenshot of xcode scheme -->

### Cocoapods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate VCR into your Xcode project using CocoaPods, specify it in your `Podfile`:


```ruby
pod 'VCR'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding VCR as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/aarons22/SwiftVCR.git", .upToNextMajor(from: "0.3.0"))
]
```

## Usage

### Recording
```
let session = VCRSession()
session.insertTape("example", record: true)
```

A json file called `example.json` will be placed into the `VCR_DIR` (defined above).

### Mulitple requests

You can record multiple requests in given session by inserting additional tapes. `VCRSession` will write out a json file for each tape inserted.

For any additional requests made, it will fallback to the actual `URLSession` request.

### Playback
```
let session = VCRSession()
session.insertTape("example")
```

This will read the file `example.json` from the `VCR_DIR` and return it in place of making the request. 

### Dependency Injection

`VCRSession` is a an instance of `URLSession`, so it can be injected into any class that uses it. For example, given an http client:
```
class HTTPClient {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func request(_ request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            completion(true)
        }

        task.resume()
    }
}
```

You can inject `VCRSession` in place of the default:
```
let session = VCRSession()
session.insertTape("example")
let client = HTTPClient(session: session)
```

## Author

Aaron Sapp, [@aaronsapp](https://twitter.com/aaronsapp)

## License

VCR is available under the MIT license. See the LICENSE file for more info.
