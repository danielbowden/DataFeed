//
//  NetworkService.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

/// Network Service used to handle network requests.
open class NetworkService {

    public typealias DataTaskCompletionHandler = (Result<(URLResponse, Data), NSError>) -> Void
    
    
    /// Custom handled network errors
    public struct NetworkError {
        
        public static let errorDomain = "DataFeed"
        
        public static let unknown = NSError(domain: errorDomain,
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Response did not contain any data"])
        
        public static let jsonConversion = NSError(domain: errorDomain,
                                                   code: 1,
                                                   userInfo: [NSLocalizedDescriptionKey: "Could not convert response data to JSON"])
    }
    
    public private(set) var session: NetworkSessionProtocol
    
    public init(session: NetworkSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// A common network request that will be started immediately and handles varying error states.
    /// - Parameters:
    ///   - request: a `URLRequest` object configured for your HTTP request
    ///   - completion: a `DataTaskCompletionHandler` consisting of a `Result` value for success or failure
    /// - Returns: The corresponding `URLSessionDataTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult open func startDataTask(withRequest request: URLRequest, completion: @escaping DataTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error as NSError? {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let serverError = NSError(domain: NetworkError.errorDomain, code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(serverError))
                return
            }
            
            completion(.success((response, data)))
        }
        
        task.resume()
        return task
    }
}

/// Protocol supporting dependency injection of mock sessions
public protocol NetworkSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSessionProtocol { }
