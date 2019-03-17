# VCR

[![CI Status](https://img.shields.io/travis/Aaron Sapp/VCR.svg?style=flat)](https://travis-ci.org/Aaron Sapp/VCR)
[![Version](https://img.shields.io/cocoapods/v/VCR.svg?style=flat)](https://cocoapods.org/pods/VCR)
[![License](https://img.shields.io/cocoapods/l/VCR.svg?style=flat)](https://cocoapods.org/pods/VCR)
[![Platform](https://img.shields.io/cocoapods/p/VCR.svg?style=flat)](https://cocoapods.org/pods/VCR)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

VCR is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VCR'
```

In order to save tapes, you will need to define `VCR_DIR` in your scheme. This should point to the directory where you want tapes to be stored. We normally use this:

|Name|Value|
|:---|:----|
|`VCR_DIR`|`$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/VCRTapes`|

<!-- TODO: Insert screenshot of xcode scheme -->

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

Aaron Sapp, sapp.aaron@gmail.com

## License

VCR is available under the MIT license. See the LICENSE file for more info.
