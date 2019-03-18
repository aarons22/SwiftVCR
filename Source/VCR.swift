//
//  VCR.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/15/19.
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
            self.data = data

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

        if let httpResponse = response as? HTTPURLResponse {
            output["headers"] = httpResponse.allHeaderFields
            output["status_code"] = httpResponse.statusCode
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
            let data = json["data"] {

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
        }
    }
}

public class VCRSession: URLSession {

    static var directory: String {
        guard let directory = ProcessInfo.processInfo.environment["VCR_DIR"] else {
            fatalError("VCR directory not defined")
        }
        return directory
    }

    /// Maintaing a "clean" session for recording actual requests.
    let passthroughSession: URLSession

    public override var delegate: URLSessionDelegate? {
        return passthroughSession.delegate
    }

    internal var tapes = [Tape]()

    public init(passthroughSession: URLSession = URLSession.shared) {
        self.passthroughSession = passthroughSession
        super.init()
    }

    public func insertTape(_ tapeName: String) {
        guard let tape = Tape(name: tapeName) else {
            fatalError("NO TAPE FOUND")
        }
        tapes.append(tape)
    }

    public func insertTape(_ tapeName: String, record: Bool) {
        if record {
            let tape = Tape(name: tapeName, record: record)
            tapes.append(tape)
        } else {
            self.insertTape(tapeName)
        }
    }

    override public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = VCRTask(session: self, request: request, completionHandler: completionHandler)
        return task
    }
}

class VCRTask: URLSessionDataTask {
    weak var session: VCRSession!
    let request: URLRequest
    let completionHandler: (Data?, URLResponse?, Error?) -> Void

    init(session: VCRSession,
         request: URLRequest,
         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session = session
        self.request = request
        self.completionHandler = completionHandler
    }

    var requestIndex = 0

    override func resume() {
        let completion = self.completionHandler

        guard session.tapes.count >= requestIndex + 1 else {
            print("[VCR] Not enough tapes for requests made, falling back to passthrough session")
            let task = session.passthroughSession.dataTask(with: request) { (data, response, error) in
                completion(data, response, error)
            }
            task.resume()
            return
        }

        let tape = session.tapes[requestIndex]
        if tape.record {
            let task = session.passthroughSession.dataTask(with: request) { (data, response, error) in
                tape.write(data: data, response: response, error: error)
                completion(data, response, error)
            }
            task.resume()
        } else {
            completion(tape.data, nil, nil)
        }

    }
}
