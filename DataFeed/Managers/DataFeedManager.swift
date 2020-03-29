//
//  DataFeedManager.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

class DataFeedManager {
    
    typealias DataFeedResult = (Result <Topic, NSError>) -> Void
    
    private var networkService: NetworkService
    
    private struct Errors {
        static let malformedRequest = NSError(domain: "DataFeed", code: 99, userInfo: [NSLocalizedDescriptionKey: "Invalid request data"])
        static let malformedResponse = NSError(domain: "DataFeed", code: 98, userInfo: [NSLocalizedDescriptionKey: "Invalid json response"])
    }
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    private var request: URLRequest? {
        guard let url = Config.factsEndpoint else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func retrieveDataFeed(completion: @escaping DataFeedResult) {
        guard let request = request else {
            completion(.failure(Errors.malformedRequest))
            return
        }
        
        networkService.startDataTask(withRequest: request) { result in
            switch result {
            case .success((_, let data)):
                guard let topic = try? JSONDecoder().decode(Topic.self, from: data) else {
                    completion(.failure(Errors.malformedResponse))
                    return
                }
                completion(.success(topic))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
