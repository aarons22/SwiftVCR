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

    init(name: String, record: Bool) {
        self.name = name
        self.record = record
    }
}

public class VCRSession: URLSession {

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

    public func insertTape(_ tapeName: String, record: Bool = false) {
        let tape = Tape(name: tapeName, record: record)
        tapes.append(tape)
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
        guard let directory = ProcessInfo.processInfo.environment["VCR_DIR"] else {
            fatalError("VCR directory not defined")
        }
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
        let output = directory.appending("/\(tape.name).json")

        let fileManager = FileManager.default

        if tape.record {
            if !fileManager.fileExists(atPath: directory) {
                do {
                    try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    fatalError("Failed to create directory: \(directory)")
                }
            }
            let task = session.passthroughSession.dataTask(with: request) { (data, response, error) in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                    print(json)

                    if let stringData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]) {
                        try? stringData.write(to: URL(fileURLWithPath: output))
                    }

                }
                completion(data, response, error)
            }
            task.resume()
        } else {
            let url = URL(fileURLWithPath: output)
            if let data = try? Data(contentsOf: url) {
                completion(data, nil, nil)
//                completion(data, response, error)
            } else {
                // User inserted tape that didn't exist
                // TODO: should a new tape be recorded in this scenario?
                fatalError("NO TAPE FOUND: \(output)")
            }
        }

    }
}
