//
//  ItemViewModel.swift
//  DataFeed
//
//  Created by Daniel Bowden on 29/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import UIKit

struct ItemViewModel {
    
    private let item: Item
    
    init(with item: Item) {
        self.item = item
    }
    
    var title: String {
        item.title.uppercased()
    }
    
    var subtitle: String {
        // Some of the descriptions have ugly leading spaces
        item.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No description available"
    }
    
    var imageUrl: URL? {
        item.imageUrl
    }
    
    static var placeholderImage: UIImage {
        let size = CGSize(width: 1.0, height: 1.0)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
