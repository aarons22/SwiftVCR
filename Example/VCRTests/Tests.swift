import XCTest
import VCR

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")

        let request = URLRequest(url: URL(string: "https://reqres.in/api/users")!)
        let session = VCRSession()

        let http = HTTPWrapper(session: session)

        let expectation = XCTestExpectation(description: "User is signed in")
        http.request(request) { (success) in

             expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

class HTTPWrapper {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func request(_ request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            completion(true)
        }

        task.resume()
    }
}
