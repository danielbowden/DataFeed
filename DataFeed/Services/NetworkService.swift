//
//  NetworkService.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation
import UIKit

/// Network Service used to handle network requests.
open class NetworkService {

    public typealias DataTaskCompletionHandler = (Result<(URLResponse, Data), NSError>) -> Void
    public typealias ImageDownloadCompletionHandler = (Result<UIImage, NSError>) -> Void
    
    /// Custom handled network errors
    public struct NetworkError {
        
        public static let errorDomain = "DataFeed"
        
        public static let unknown = NSError(domain: errorDomain,
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Response did not contain any data"])
        public static let imageCreation = NSError(domain: errorDomain,
                                                  code: 1,
                                                  userInfo: [NSLocalizedDescriptionKey: "Could not create image from reponse data"])
    }
    
    public private(set) var session: NetworkSessionProtocol
    
    public init(session: NetworkSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// A common network request that will be started immediately and handles varying error states.
    /// - Parameters:
    ///   - request: a `URLRequest` object configured for your HTTP request
    ///   - completion: a `DataTaskCompletionHandler` consisting of a `Result` value for success, containing the response and data, or failure, containing the error.
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
    
    /// Async network request to retrieve an image from a given URL.
    /// - Parameters:
    ///   - url: the image `URL`.
    ///   - completion: a `ImageDownloadCompletionHandler` consisting of a `Result` value for success, containg the `UIImage`, or failure, containing the error.
    /// - Returns: The corresponding `URLSessionDataTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult open func startImageDownload(withUrl url: URL, completion: @escaping ImageDownloadCompletionHandler) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        let task = startDataTask(withRequest: request) { result in
            switch result {
            case .success(let (_, data)):
                guard let image = UIImage(data: data) else {
                    completion(.failure(NetworkError.imageCreation))
                    return
                }
                completion(.success(image))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

public extension UIImageView {
    /// Helper extension to support `UIImageView` to download an image from a given URL.
    /// - Parameters:
    ///   - url: the image `URL`.
    ///   - placeholderImage: a `UIImage` shown while the image is downloading.
    func image(fromUrl url: URL, placeholderImage: UIImage?) {
        let networkService = NetworkService()
        image = placeholderImage
        networkService.startImageDownload(withUrl: url) { [weak self] result in
            guard let self = self else { return }
            if case let .success(image) = result {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

/// Protocol supporting dependency injection of mock sessions
public protocol NetworkSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSessionProtocol { }
