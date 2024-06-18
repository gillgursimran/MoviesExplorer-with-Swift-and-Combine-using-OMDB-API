//
//  URLSessionProtocol.swift
//  MoviesExplorer
//
//  Created by Gursimran Singh Gill on 2024-06-18.
//

import Foundation
import Combine

public protocol URLSessionProtocol {
    func sendRequest(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionProtocol {
    public func sendRequest(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        self.dataTaskPublisher(for: request)
            .mapError { $0 as URLError }
            .eraseToAnyPublisher()
    }
}
