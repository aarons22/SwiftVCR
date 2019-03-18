//
//  Tape.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/17/19.
//

import Foundation

internal class Tape {
    let name: String
    let record: Bool
    var data: Data?
    var response: URLResponse?

    init(name: String, record: Bool) {
        self.name = name
        self.record = record

        if record {
            let fileManager = FileManager.default
            let directory = VCRSession.directory
            if !fileManager.fileExists(atPath: directory) {
                do {
                    try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    fatalError("Failed to create directory: \(directory)")
                }
            }
        }
    }

    init?(name: String) {
        self.name = name
        self.record = false

        let output = VCRSession.directory.appending("/\(name).json")
        let url = URL(fileURLWithPath: output)
        if let data = try? Data(contentsOf: url) {
            if let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]),
                let dict = json as? [String: Any] {
                self.decode(json: dict)
            }
        } else {
            return nil
        }
    }

    func write(data: Data?, response: URLResponse?, error: Error?) {
        let outputDir = VCRSession.directory.appending("/\(name).json")
        var output = [String: Any]()
        var contentType: String?

        if let httpResponse = response as? HTTPURLResponse,
            let url = httpResponse.url {
            output["headers"] = httpResponse.allHeaderFields
            output["status_code"] = httpResponse.statusCode
            output["url"] = url.absoluteString
            contentType = httpResponse.allHeaderFields["Content-Type"] as? String
        }

        if let contentType = contentType {
            output["data"] = self.encode(data, contentType: contentType)
        }

        if let stringData = try? JSONSerialization.data(withJSONObject: output, options: [.prettyPrinted]) {
            try? stringData.write(to: URL(fileURLWithPath: outputDir))
        }
    }

    private func encode(_ data: Data?, contentType: String) -> Any? {
        if let data = data {
            // JSON Response
            if contentType.contains("application/json"),
                let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                return json
            }

            if contentType.contains("text") {
                // UTF-8 Response
                if contentType.contains("UTF-8") {
                    if let string = String.init(data: data, encoding: .utf8) {
                        return string
                    }
                } else {
                    // ascii Response
                    if let string = String.init(data: data, encoding: .ascii) {
                        return string
                    }
                }
            }
        }
        return nil
    }

    private func decode(json: [String: Any]) {
        if let headers = json["headers"] as? [AnyHashable : Any],
            let contentType = headers["Content-Type"] as? String,
            let statusCode = json["status_code"] as? Int,
            let urlString = json["url"] as? String,
            let url = URL(string: urlString),
            let data = json["data"] {

            // DATA

            if contentType.contains("application/json"),
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
                self.data = jsonData
            }

            if contentType.contains("text") {
                // UTF-8 Response
                if contentType.contains("UTF-8") {
                    if let string = data as? String {
                        self.data = string.data(using: .utf8)
                    }
                } else {
                    // ascii Response
                    if let string = data as? String {
                        self.data = string.data(using: .ascii)
                    }
                }
            }

            // RESPONSE
            let response = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: headers as? [String : String])
            self.response = response
        }
    }
}
