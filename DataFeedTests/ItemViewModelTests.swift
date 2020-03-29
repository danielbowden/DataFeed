//
//  ItemViewModelTests.swift
//  DataFeedTests
//
//  Created by Daniel Bowden on 29/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import XCTest

@testable import DataFeed

class ItemViewModelTests: XCTestCase {

    func testItemViewModelReturnsExpectedValuesWhenProvidedItem() {
        let testData = """
        {
        "title":"First item",
        "description":"First item description",
        "imageHref":"http://testImageURL.com/image.jpg"
        }
        """.data(using: .utf8)!
        
        let item = createTestItem(with: testData)
        let viewModel = ItemViewModel(with: item)
        
        XCTAssertEqual(viewModel.title, "FIRST ITEM")
        XCTAssertEqual(viewModel.subtitle, "First item description")
        XCTAssertEqual(viewModel.imageUrl?.absoluteString, "http://testImageURL.com/image.jpg")
    }
    
    func testItemViewModelReturnsDefaultDescriptionWhenNoDescriptioninJson() {
        let testData = """
        {
        "title":"First item",
        "description":null,
        "imageHref":"http://testImageURL.com/image.jpg"
        }
        """.data(using: .utf8)!
        
        let item = createTestItem(with: testData)
        let viewModel = ItemViewModel(with: item)
        
        XCTAssertEqual(viewModel.subtitle, "No description available")
    }
    
    func testItemViewModelReturnsNilImageUrlWhenNoImageUrlInJson() {
        let testData = """
        {
        "title":"First item",
        "description":"First item description",
        "imageHref":null
        }
        """.data(using: .utf8)!
        
        let item = createTestItem(with: testData)
        let viewModel = ItemViewModel(with: item)
        
        XCTAssertNil(viewModel.imageUrl)
    }
    
    func testItemViewModelPlaceholderImageReturnsUIImage(){
        let image = ItemViewModel.placeholderImage
        XCTAssertNotNil(image)
    }
    
    private func createTestItem(with testData: Data) -> Item {
        return try! JSONDecoder().decode(Item.self, from: testData)
    }
}
