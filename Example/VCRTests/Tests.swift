import XCTest
import VCR

class Tests: XCTestCase {
    func testJson() {
        let request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()
        session.insertTape("json-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "json response succeeds")
        http.request(request) { (success, url) in
            expectation.fulfill()
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users")
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlUtf8() {
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        let session = VCRSession()
        session.insertTape("html-utf8-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success, url) in
            expectation.fulfill()
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://www.google.com/")
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlAscii() {
        let request = URLRequest(url: URL(string: "https://www.apple.com")!)
        let session = VCRSession()
        session.insertTape("html-ascii-response")

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success, url) in
            expectation.fulfill()
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://www.apple.com/")
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
        http.request(request) { (success, url) in
            expectation.fulfill()
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users")
        }

        let expectation2 = XCTestExpectation(description: "json response succeeds")
        request = URLRequest(url: URL(string: "https://reqres.in/api/users/1")!)
        http.request(request) { (success, url) in
            expectation2.fulfill()
            XCTAssertTrue(success)
            XCTAssertEqual(url?.absoluteString, "https://reqres.in/api/users/1")
        }

        wait(for: [expectation, expectation2], timeout: 5.0)
    }
}

class HTTPClient {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func request(_ request: URLRequest, completion: @escaping (Bool, URL?) -> Void) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            completion(true, response?.url)
        }

        task.resume()
    }
}
