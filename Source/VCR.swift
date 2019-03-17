//
//  VCR.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/15/19.
//

import Foundation

public class VCRSession: URLSession {

    /// Maintaing a "clean" session for recording actual requests.
    let passthroughSession: URLSession

    public override var delegate: URLSessionDelegate? {
        return passthroughSession.delegate
    }

    public init(passthroughSession: URLSession = URLSession.shared) {
        self.passthroughSession = passthroughSession
        super.init()
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

    override func resume() {
        guard let directory = ProcessInfo.processInfo.environment["VCR_DIR"] else {
            fatalError("VCR directory not defined")
        }
        let completion = self.completionHandler
        let task = session.passthroughSession.dataTask(with: request) { (data, response, error) in
            let output = directory.appending("/output.json")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: directory) {
                do {
                    try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("[VCR] Failed to create directory.")
                }
            } else {
                let url = URL(fileURLWithPath: output)
                if let data = try? Data(contentsOf: url) {
                    completion(data, response, error)
                    return
                }
            }

            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                print(json)

                if let stringData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]) {
                    try? stringData.write(to: URL(fileURLWithPath: output))
                }

            }
            completion(data, response, error)
        }
        task.resume()
    }
}
