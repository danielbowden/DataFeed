//
//  UnkeyedDecodingContainer+Extension.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import Foundation

private struct AnyCodable: Codable {}

// Skip decodable array elements that fail to parse
// by decoding into a throwaway object which increments
// the container index position.
extension UnkeyedDecodingContainer {
    public mutating func skipElement() {
        _ = try? decode(AnyCodable.self)
    }
}
