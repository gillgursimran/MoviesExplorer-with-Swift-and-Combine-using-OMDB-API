//
//  MockURLSession.swift
//  MoviesExplorerTests
//
//  Created by Gursimran Singh Gill on 2024-06-18.
//

import Foundation
import Combine
@testable import MoviesExplorer

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: URLError?
    
    func sendRequest(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            let output = (data: data ?? Data(), response: response ?? URLResponse())
            return Just(output)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
    }
}
