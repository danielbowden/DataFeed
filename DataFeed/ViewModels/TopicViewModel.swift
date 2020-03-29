//
//  TopicViewModel.swift
//  DataFeed
//
//  Created by Daniel Bowden on 29/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

struct TopicViewModel {
    
    private let topic: Topic
    
    init(with topic: Topic) {
        self.topic = topic
    }
    
    var navigationTitle: String {
        topic.title
    }
    
    var numberOfItems: Int {
        topic.items.count
    }
    
    func item(at index: Int) -> Item? {
        guard topic.items.indices.contains(index) else { return nil }
        return topic.items[index]
    }
}
