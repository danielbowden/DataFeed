//
//  DataFeedManagerTests.swift
//  DataFeedTests
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import XCTest

@testable import DataFeed

class DataFeedManagerTests: XCTestCase {
    
    private var mockNetworkService: MockNetworkService!

    override func setUp() {
        mockNetworkService = MockNetworkService()
    }

    override func tearDown() {
        mockNetworkService = nil
    }
    
    func testDataFeedManagerRequestsAndSerializesTopic() {
        let expectation = XCTestExpectation()
        let testData = """
        {
        "title":"My Title",
        "rows":[
            {
            "title":"First item",
            "description":"First item description",
            "imageHref":"http://testImageURL.com/image.jpg"
            },
            {
            "title":"Second item",
            "description":"Second item description",
            "imageHref":"http://testImageURL.com/image2.jpg"
            }
        ]
        }
        """.data(using: .utf8)!
        
        let manager = DataFeedManager(networkService: mockNetworkService)
        mockNetworkService.dataResult = .success((URLResponse(), testData))
        
        manager.retrieveDataFeed { result in
            switch result {
            case .success(let topic):
                XCTAssertNotNil(topic)
                XCTAssertEqual(topic.title, "My Title")
                XCTAssertEqual(topic.items.count, 2)
                XCTAssertEqual(topic.items.first?.title, "First item")
                XCTAssertEqual(topic.items.first?.description, "First item description")
                XCTAssertEqual(topic.items.first?.imageUrl?.absoluteString, "http://testImageURL.com/image.jpg")
                expectation.fulfill()
            case .failure(_): XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDataFeedManagerSerializesOptionalObjects() {
        let expectation = XCTestExpectation()
        let testData = """
        {
        "title":"My Title",
        "rows":[
            {
            "title":"First item",
            "description":null,
            "imageHref":null
            }
        ]
        }
        """.data(using: .utf8)!
        
        let manager = DataFeedManager(networkService: mockNetworkService)
        mockNetworkService.dataResult = .success((URLResponse(), testData))
        
        manager.retrieveDataFeed { result in
            switch result {
            case .success(let topic):
                XCTAssertNotNil(topic)
                XCTAssertEqual(topic.items.count, 1)
                XCTAssertEqual(topic.items.first?.title, "First item")
                XCTAssertNil(topic.items.first?.description)
                XCTAssertNil(topic.items.first?.imageUrl?.absoluteString)
                expectation.fulfill()
            case .failure(_): XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDataFeedManagerExcludesNullItems() {
        let expectation = XCTestExpectation()
        let testData = """
        {
        "title":"My Title",
        "rows":[
            {
            "title":null,
            "description":null,
            "imageHref":null
            },
            {
            "title":"Second item",
            "description":"Second item description",
            "imageHref":"http://testImageURL.com/image2.jpg"
            }
        ]
        }
        """.data(using: .utf8)!
        
        let manager = DataFeedManager(networkService: mockNetworkService)
        mockNetworkService.dataResult = .success((URLResponse(), testData))
        
        manager.retrieveDataFeed { result in
            switch result {
            case .success(let topic):
                XCTAssertNotNil(topic)
                XCTAssertEqual(topic.items.count, 1)
                XCTAssertEqual(topic.items.first?.title, "Second item")
                expectation.fulfill()
            case .failure(_): XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
