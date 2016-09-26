//
//  Graph.swift
//  SwiftGraph
//
//  Created by Kevin Lundberg on 9/25/16.
//  Copyright © 2016 Kevin Lundberg. All rights reserved.
//

import Foundation

struct Graph {
    enum Type: String {
        case undirected = "graph"
        case directed = "digraph"
    }

    var type: Type
    var name: String

    init(type: Type = .undirected, name: String = "") {
        self.type = type
        self.name = name
    }
}

extension String {
    func removingRepeatedWhitespace() -> String {
        return self.stringByReplacingOccurrencesOfString("\\s+",
                                                         withString: " ",
                                                         options: NSStringCompareOptions.RegularExpressionSearch,
                                                         range: self.startIndex..<self.endIndex)
    }
}

extension Graph: CustomStringConvertible {
    var description: String {
        return "\(type.rawValue) \(name) {}".removingRepeatedWhitespace()
    }
}
