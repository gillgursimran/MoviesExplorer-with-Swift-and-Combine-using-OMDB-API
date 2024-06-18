//
//  RequestHandlerTest.swift
//  MoviesExplorerTests
//
//  Created by Gursimran Singh Gill on 2024-06-18.
//

import Foundation
import XCTest
import Combine
@testable import MoviesExplorer

class RequestHandlerTest: XCTestCase {
    var requestHandler: RequestHandler!
    var mockURLSession: MockURLSession!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockURLSession = MockURLSession()
        requestHandler = RequestHandler.shared
        requestHandler.setSession(mockURLSession)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        requestHandler = nil
        mockURLSession = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testFetchDataSuccess() {
        let expectedData = "movies found".data(using: .utf8)
        mockURLSession.data = expectedData
        mockURLSession.response = HTTPURLResponse(url: URL(string: "https://www.omdb.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let url = "https://www.omdb.com"
        let expectation = self.expectation(description: "Fetch data success")
        var receivedData: Data?

        requestHandler.sendRequest(url: url, params: [:])
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            }, receiveValue: { data in
                receivedData = data
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedData, expectedData)
    }

    func testFetchDataFailure() {
        let expectedError = URLError(.badServerResponse)
        mockURLSession.error = expectedError
        let url = "https://www.omdb.com"
        let expectation = self.expectation(description: "Fetch data failure")
        var receivedError: URLError?

        requestHandler.sendRequest(url: url, params: [:])
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error as? URLError
                    expectation.fulfill()
                }
            }, receiveValue: { data in
                XCTFail("Unexpected data: \(data)")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, expectedError)
    }
}
