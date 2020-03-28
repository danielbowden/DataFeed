//
//  Config.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

enum Config {
    
    private static let values = Bundle.main.infoDictionary
    
    static var factsEndpoint: URL? {
        guard let urlString = Config.values?["DF_FACTS_ENDPOINT"] as? String else { return nil }
        return URL(string: urlString)
    }
}
