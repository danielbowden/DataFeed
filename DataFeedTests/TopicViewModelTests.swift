//
//  TopicViewModelTests.swift
//  DataFeedTests
//
//  Created by Daniel Bowden on 29/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import XCTest

@testable import DataFeed

class TopicViewModelTests: XCTestCase {

    func testTopicViewModelReturnsExpectedValuesWhenProvidedTopic() {
        let testData = """
        {
        "title":"My Title",
        "rows":[
            {
            "title":"First item",
            "description":"First item description",
            "imageHref":"http://testImageURL.com/image.jpg"
            }
        ]
        }
        """.data(using: .utf8)!
        
        let topic = createTestTopic(with: testData)
        let viewModel = TopicViewModel(with: topic)
        
        XCTAssertEqual(viewModel.navigationTitle, "My Title")
        XCTAssertEqual(viewModel.numberOfItems, 1)
        let item = viewModel.item(at: 0)
        XCTAssertEqual(item?.title, "First item")
    }
    
    func testTopicViewModelHandlesEmptyItems() {
        let testData = """
        {
        "title":"My Title",
        "rows":[]
        }
        """.data(using: .utf8)!
        
        let topic = createTestTopic(with: testData)
        let viewModel = TopicViewModel(with: topic)
        
        XCTAssertEqual(viewModel.navigationTitle, "My Title")
        XCTAssertEqual(viewModel.numberOfItems, 0)
        XCTAssertNil(viewModel.item(at: 0))
    }
    
    private func createTestTopic(with testData: Data) -> Topic {
        return try! JSONDecoder().decode(Topic.self, from: testData)
    }
}

