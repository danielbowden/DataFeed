//
//  NetworkServiceTests.swift
//  DataFeedTests
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import XCTest

@testable import DataFeed

class NetworkServiceTests: XCTestCase {
        
    private var mockSession = MockNetworkSession()
    private var networkService: NetworkService!
    private var request = URLRequest(url: URL(fileURLWithPath: "test"))
    private let httpResponse200 = HTTPURLResponse(url: URL(fileURLWithPath: "test"), statusCode: 200, httpVersion: nil, headerFields: nil)!
    private let httpResponse404 = HTTPURLResponse(url: URL(fileURLWithPath: "test"), statusCode: 404, httpVersion: nil, headerFields: nil)!
    
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService(session: mockSession)
        
    }
    
    override func tearDown() {
        super.tearDown()
        networkService = nil
        mockSession.data = nil
        mockSession.urlResponse = nil
        mockSession.error = nil
    }
    
    func testNetworkGETRequestReturnsValidResponse() {
        let expectation = XCTestExpectation()
        
        let mockResponseData = """
        {"test":"data"}
        """.data(using: .utf8)!
        mockSession.data = mockResponseData
        mockSession.urlResponse = httpResponse200
        
        networkService.startDataTask(withRequest: request) { result in
            switch result {
            case .success((let response, let data)):
                XCTAssertNotNil(data)
                XCTAssertEqual(String(data: data, encoding: .utf8)!, "{\"test\":\"data\"}")
                XCTAssertEqual((response as! HTTPURLResponse).statusCode, 200)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Request should not fail")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkRequestReturnsErrorOnNetworkError() {
        let expectation = XCTestExpectation()
        networkService.startDataTask(withRequest: request) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, NetworkService.NetworkError.unknown)
                expectation.fulfill()
            case .success: XCTFail("Request should not succeed")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkRequestHandlesNonSuccessfulStatusCodeAsFailure() {
        let expectation = XCTestExpectation()
        mockSession.data = """
        {"error":"custom error response"
        """.data(using: .utf8)!
        mockSession.urlResponse = httpResponse404
        networkService.startDataTask(withRequest: request) { result in
            switch result {
            case .success(_):
                XCTFail("Request should not succeed")
            case .failure(let error):
                XCTAssertEqual(error.code, 404)
                XCTAssertEqual(error.domain, "DataFeed")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkRequestReturnsUnhandledInternalError() {
        let expectation = XCTestExpectation()
        mockSession.error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: "Localised description"])
        networkService.startDataTask(withRequest: request) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error.localizedDescription, "Localised description")
                expectation.fulfill()
            case .success: XCTFail("Request should not succeed")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkRequestContainsExpectedRequestContents() {
        let expectation = XCTestExpectation()
        let mockNetworkService = MockNetworkService()
        mockNetworkService.dataResult = .success((URLResponse(), Data()))
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["test":"data"], options: JSONSerialization.WritingOptions())
        
        let task = mockNetworkService.startDataTask(withRequest: request) { result in
            expectation.fulfill()
        }
        
        XCTAssertEqual(task.originalRequest!.httpMethod, "POST")
        XCTAssertEqual(task.originalRequest!.url!.absoluteString, "file:///test")
        let requestJSONString = String(data: task.originalRequest!.httpBody!, encoding: .utf8)!
        XCTAssertEqual(requestJSONString, """
        {"test":"data"}
        """)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testImageDownloadNetworkRequestCanReturnUIImage() {
        let expectation = XCTestExpectation()
        let path = Bundle(for: NetworkServiceTests.self).path(forResource: "TestImage", ofType: "png")!
        let imageData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        mockSession.data = imageData
        mockSession.urlResponse = httpResponse200
        
        networkService.startImageDownload(withUrl: URL(fileURLWithPath: "test")) { result in
            switch result {
            case .success(let image):
                XCTAssertNotNil(image)
                XCTAssertTrue(image.isKind(of: UIImage.self))
                expectation.fulfill()
            case .failure(_):
                XCTFail("Request should not fail")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testImageDownloadNetworkRequestReturnsFailureForBadImageData() {
        let expectation = XCTestExpectation()
        mockSession.data = """
        {"data":"not an image"
        """.data(using: .utf8)!
        mockSession.urlResponse = httpResponse200
        
        networkService.startImageDownload(withUrl: URL(fileURLWithPath: "test")) { result in
            switch result {
            case .success(_):
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error.domain, "DataFeed")
                XCTAssertEqual(error.code, 1)
                XCTAssertEqual(error.localizedDescription, "Could not create image from reponse data")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testImageDownloadNetworkRequestReturnsFailureForBadResponse() {
        let expectation = XCTestExpectation()
        mockSession.data = """
        {"error":"image not found"
        """.data(using: .utf8)!
        mockSession.urlResponse = httpResponse404
        
        networkService.startImageDownload(withUrl: URL(fileURLWithPath: "test")) { result in
            switch result {
            case .success(_):
                XCTFail("Request should fail")
            case .failure(_):
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
