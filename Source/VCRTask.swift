//
//  VCRTask.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/17/19.
//

import Foundation

class VCRTask: URLSessionDataTask {
    weak var session: VCRSession!
    let tape: Tape
    let request: URLRequest
    let completionHandler: (Data?, URLResponse?, Error?) -> Void

    init(session: VCRSession,
         tape: Tape,
         request: URLRequest,
         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session = session
        self.tape = tape
        self.request = request
        self.completionHandler = completionHandler
    }

    var requestIndex: Int = 0

    override func resume() {
        let completion = self.completionHandler

        if tape.record {
            let currentTape = tape
            let task = session.passthroughSession.dataTask(with: request) { (data, response, error) in
                currentTape.write(data: data, response: response, error: error)
                completion(data, response, error)
            }
            task.resume()
        } else {
            completion(tape.data, tape.response, nil)
        }
    }
}
