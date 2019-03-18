//
//  VCRTask.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/17/19.
//

import Foundation

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
            completion(tape.data, tape.response, nil)
        }

    }
}
