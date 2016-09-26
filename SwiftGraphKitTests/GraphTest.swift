//
//  GraphTest.swift
//  SwiftGraph
//
//  Created by Kevin Lundberg on 9/25/16.
//  Copyright © 2016 Kevin Lundberg. All rights reserved.
//

import XCTest
@testable import SwiftGraphKit

class GraphTest: XCTestCase {

    func testEmptyGraph() {
        let graph = Graph()

        XCTAssertEqual(graph.description, "graph {}")
    }

    func testEmptyDirectedGraph() {
        let graph = Graph(type: .directed)

        XCTAssertEqual(graph.description, "digraph {}")
    }

    func testEmptyGraphWithName() {
        let graph = Graph(name: "foo")

        XCTAssertEqual(graph.description, "graph foo {}")
    }

}
