//
//  NetworkServiceMock.swift
//  DataFeedTests
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

@testable import DataFeed

/// Mock of the Network Session to be injected into unit tests to
/// prevent real network requests to the Internet and control responses
class MockNetworkSession: NetworkSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.data
        let urlResponse = self.urlResponse
        let error = self.error
        
        return MockURLSessionDataTask {
            completionHandler(data, urlResponse, error)
        }
    }
}

/// Partial mock of data task to override the resume method and control the callback
class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

/// Partial mock of the network service to override Result for simulating .success and .failure
class MockNetworkService: NetworkService {
    var dataResult: Result<(URLResponse, Data), NSError>?

    @discardableResult override func startDataTask(withRequest request: URLRequest, completion: @escaping NetworkService.DataTaskCompletionHandler) -> URLSessionDataTask {
        if let result = dataResult {
            completion(result)
        }

        return URLSession.shared.dataTask(with: request)
    }
}
