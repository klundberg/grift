//
//  GraphTest.swift
//  SwiftGraph
//
//  Created by Kevin Lundberg on 9/25/16.
//  Copyright © 2016 Kevin Lundberg. All rights reserved.
//

import XCTest
@testable import SwiftGraphKit

class GraphTests: XCTestCase {

    func testEmptyGraph() {
        let graph = Graph()

        XCTAssertEqual(graph.description, "graph { }")
    }

    func testEmptyDirectedGraph() {
        let graph = Graph(type: .directed)

        XCTAssertEqual(graph.description, "digraph { }")
    }

    func testEmptyGraphWithName() {
        let graph = Graph(name: "foo")

        XCTAssertEqual(graph.description, "graph foo { }")
    }

    func testGraphWithOneNode() {
        let graph = Graph(statements: [Node("A")])

        XCTAssertEqual(graph.description, "graph { A }")
    }


    func testGraphWithTwoNodes() {
        let graph = Graph(statements: [Node("A"), Node("B")])

        XCTAssertEqual(graph.description, "graph { A; B }")
    }

    func testUndirectedGraphWithOneEdge() {
        let graph = Graph(statements: [Edge(from: Node("A"), to:Node("B"))])

        XCTAssertEqual(graph.description, "graph { A -- B }")
    }

    func testDirectedGraphWithOneEdge() {
        let graph = Graph(type: .directed,
                          statements: [Edge(from: Node("A"), to:Node("B"))])

        XCTAssertEqual(graph.description, "digraph { A -> B }")
    }

    func testUndirectedGraphWithTwoEdges() {
        let graph = Graph(statements: [Edge(from: Node("A"), to:Node("B")),
                                       Edge(from: Node("B"), to:Node("C"))])

        XCTAssertEqual(graph.description, "graph { A -- B; B -- C }")
    }

    func testDirectedGraphWithTwoEdges() {
        let graph = Graph(type: .directed,
                          statements: [Edge(from: Node("A"), to:Node("B")),
                            Edge(from: Node("B"), to:Node("C"))])

        XCTAssertEqual(graph.description, "digraph { A -> B; B -> C }")
    }

    func testUndirectedGraphWithSubgraph() {
        let graph = Graph(statements: [Subgraph("foo")])

        XCTAssertEqual(graph.description, "graph { subgraph foo { } }")
    }

    func testComplexUndirectedGraphWithSubgraph() {
        let graph = Graph(statements: [Edge(from: Node("A"), to: Node("B")),
                                       Subgraph(statements: [Edge(from: Node("C"), to: Node("D"))])])

        XCTAssertEqual(graph.description, "graph { A -- B; subgraph { C -- D } }")
    }
}
