import XCTest
import VCR

class Tests: XCTestCase {
    func testJson() {
        let request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()
        session.insertTape("json-response", record: true)

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "json response succeeds")
        http.request(request) { (success) in
            expectation.fulfill()
            XCTAssertTrue(success)
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlUtf8() {
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        let session = VCRSession()
        session.insertTape("html-utf8-response", record: true)

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success) in
            expectation.fulfill()
            XCTAssertTrue(success)
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testHtmlAscii() {
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        let session = VCRSession()
        session.insertTape("html-ascii-response", record: true)

        let http = HTTPClient(session: session)

        let expectation = XCTestExpectation(description: "html response succeeds")
        http.request(request) { (success) in
            expectation.fulfill()
            XCTAssertTrue(success)
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

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
