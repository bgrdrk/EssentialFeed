import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }

    func test_getFromURL_performsGETRequestWithCorrectURL() {
        let url = anyURL
        let expectation = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }

        makeSUT().get(from: anyURL) { _ in }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as NSError?
        XCTAssertEqual(requestError.domain, receivedError?.domain)
        XCTAssertEqual(requestError.code, receivedError?.code)
    }

    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: anyHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: nil)))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData
        let response = anyHTTPURLResponse
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(data, receivedValues?.data)
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))

        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?),
                                 file: StaticString = #file,
                                 line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)

        switch result {
        case .success(let result):
            return (result.0, result.1)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                                taskHandler: (HTTPClientTask) -> Void = { _ in },
                                file: StaticString = #file,
                                line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?,
                           taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #file,
                           line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)
        let expectation = expectation(description: "wait for completion")

        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL) { result in
            receivedResult = result
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)

        return receivedResult
    }

    // MARK: - Helper variables

    private var anyData: Data {
        Data("any data".utf8)
    }

    private var nonHTTPURLResponse: URLResponse {
        URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?,
                         response: URLResponse?,
                         error: Error?) {
            stub = .init(
                data: data,
                response: response,
                error: error
            )
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            guard let stub = URLProtocolStub.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
