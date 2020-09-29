import XCTest
import VCR

class Tests: XCTestCase {
    func testJson() {
        let request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()
        session.insertTape("json-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "json response succeeds")
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users")
            XCTAssertEqual(statusCode, 200)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlUtf8() {
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        let session = VCRSession()
        session.insertTape("html-utf8-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://www.google.com/")
            XCTAssertEqual(statusCode, 200)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlAscii() {
        let request = URLRequest(url: URL(string: "https://www.apple.com")!)
        let session = VCRSession()
        session.insertTape("html-ascii-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://www.apple.com/")
            XCTAssertEqual(statusCode, 200)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testMultiple() {
        var request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()
        session.insertTape("first-response")
        session.insertTape("second-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "json response succeeds")
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users")
            XCTAssertEqual(statusCode, 200)
            expectation.fulfill()
        }

        let expectation2 = XCTestExpectation(description: "json response succeeds")
        request = URLRequest(url: URL(string: "https://reqres.in/api/users/1")!)
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users/1")
            XCTAssertEqual(statusCode, 200)
            expectation2.fulfill()
        }

        wait(for: [expectation, expectation2], timeout: 5.0)
    }

    func test503() {
        let request = URLRequest(url: URL(string: "http://httpbin.org/status/503")!)
        let session = VCRSession()
        session.insertTape("503-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "503 response fails")
        http.request(request) { (success, url, statusCode) in
            XCTAssertTrue(success)
            XCTAssertEqual(statusCode, 503)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    @available(iOS 13.0, *)
    func testDataTaskPublisher() {
        let request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()
        session.insertTape("json-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "json response succeeds")
        http.request(request)
            .sink(receiveCompletion: { _ in }) { result in
                switch result {
                case (let data, let response):
                    XCTAssertNotNil(data)
                    XCTAssertEqual(response.mimeType, "application/json")
                    expectation.fulfill()
                }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

import Combine

class HTTPClient {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func request(_ request: URLRequest, completion: @escaping (Bool, URL?, Int) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(true, response?.url, httpResponse.statusCode)
            }
        }

        task.resume()
    }

    @available(iOS 13.0, *)
    func request(_ request: URLRequest) -> URLSession.DataTaskPublisher {
        return session.dataTaskPublisher(for: request)
    }
}
