//
//  Topic.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

struct Topic: Decodable {
    let title: String
    let items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case title
        case items = "rows"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        var itemsContainer = try values.nestedUnkeyedContainer(forKey: .items)
        var items = [Item]()
        
        // Response contains some completely null 'Items',
        // discard them during parsing rather than inefficiently
        // using compactMap on a potentially large array
        while !itemsContainer.isAtEnd {
            guard let item = try? itemsContainer.decode(Item.self) else {
                itemsContainer.skipElement()
                continue
            }
            items.append(item)
        }
        self.items = items
    }
}
