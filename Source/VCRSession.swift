//
//  VCR.swift
//  Pods-VCR_Example
//
//  Created by Aaron Sapp on 3/15/19.
//

import Foundation

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
