//
//  RequestHandler.swift
//  MoviesExplorer
//
//  Created by Gursimran Singh Gill on 2024-06-16.
//

import Foundation
import Combine

enum MIMETypes: String {
    case json = "application/json"
}

enum RequestType: String {
    case post = "POST"
    case get = "GET"
}

enum ApiQueryKeys : String {
    case authKey = "apikey"
    case title = "t"
    case search = "s"
    case page = "page"
}

class RequestHandler {
    static let apiKey = "5a5de648"
    static let moviesSearchUrl = "http://www.omdbapi.com/"

    private var session: URLSessionProtocol
    private let requestTimeout = TimeInterval(30)
    private(set) var method: String = RequestType.get.rawValue
    private(set) var accept: String = MIMETypes.json.rawValue

    static let shared = RequestHandler()
    private init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
        
    public func method(_ method: String) -> RequestHandler {
        self.method = method
        return self
    }
    
    public func accept(_ accept: String) -> RequestHandler {
        self.accept = accept
        return self
    }
    
    func setSession(_ session: URLSessionProtocol) {
        self.session = session
    }
    
    private func createURLWithParams(baseURL: String, params: [String: String]) -> URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents?.url
    }
    
    func sendRequest(url: String, params: [String: String]) -> AnyPublisher<Data, Error> {
        guard let url = createURLWithParams(baseURL: url, params: params) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = requestTimeout
        request.cachePolicy = .reloadRevalidatingCacheData
        request.httpMethod = method
        
        if !accept.isEmpty {
            request.setValue(accept, forHTTPHeaderField: "Accept")
        }
            
        return session.sendRequest(for: request)
                .map { $0.data }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
    }
}
