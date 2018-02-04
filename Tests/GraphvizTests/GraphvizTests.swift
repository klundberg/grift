@testable import Graphviz
import SwiftGraph
import XCTest

class GraphvizTests: XCTestCase {

    func testEmptyGraph() {
        let graph = Graphviz()

        XCTAssertEqual(graph.description, "graph { }")
    }

    func testEmptyDirectedGraph() {
        let graph = Graphviz(type: .directed)

        XCTAssertEqual(graph.description, "digraph { }")
    }

    func testEmptyGraphWithName() {
        let graph = Graphviz(name: "foo")

        XCTAssertEqual(graph.description, "graph foo { }")
    }

    func testGraphWithOneNode() {
        let graph = Graphviz(statements: [Node("A")])

        XCTAssertEqual(graph.description, "graph { \"A\" }")
    }

    func testGraphWithTwoNodes() {
        let graph = Graphviz(statements: [Node("A"), Node("B")])

        XCTAssertEqual(graph.description, "graph { \"A\"; \"B\" }")
    }

    func testUndirectedGraphWithOneEdge() {
        let graph = Graphviz(statements: ["A" >> "B"])

        XCTAssertEqual(graph.description, "graph { \"A\" -- \"B\" }")
    }

    func testDirectedGraphWithOneEdge() {
        let graph = Graphviz(type: .directed,
                          statements: ["A" >> "B"])

        XCTAssertEqual(graph.description, "digraph { \"A\" -> \"B\" }")
    }

    func testUndirectedGraphWithTwoEdges() {
        let graph = Graphviz(statements: ["A" >> "B", "B" >> "C"])

        XCTAssertEqual(graph.description, "graph { \"A\" -- \"B\"; \"B\" -- \"C\" }")
    }

    func testDirectedGraphWithTwoEdges() {
        let graph = Graphviz(type: .directed,
                          statements: ["A" >> "B", "B" >> "C"])

        XCTAssertEqual(graph.description, "digraph { \"A\" -> \"B\"; \"B\" -> \"C\" }")
    }

    func testUndirectedGraphWithSubgraph() {
        let graph = Graphviz(statements: [Subgraph("foo")])

        XCTAssertEqual(graph.description, "graph { subgraph foo { } }")
    }

    func testComplexUndirectedGraphWithSubgraph() {
        let graph = Graphviz(statements: ["A" >> "B",
                                       Subgraph(statements: ["C" >> "D"])])

        XCTAssertEqual(graph.description, "graph { \"A\" -- \"B\"; subgraph { \"C\" -- \"D\" } }")
    }

    func testGraphWithClusteredSubgraph() {
        let graph = Graphviz(statements: [Subgraph("blah", isCluster: true)])

        XCTAssertEqual(graph.description, "graph { subgraph cluster_blah { } }")
    }

    func testSerializingBasicGraph() {
        let graph = UnweightedGraph<String>()
        _ = graph.addVertex("A")
        _ = graph.addVertex("B")
        _ = graph.addVertex("C")

        graph.addEdge(from: "A", to: "B", directed: true)
        graph.addEdge(from: "B", to: "C", directed: true)
        graph.addEdge(from: "C", to: "A", directed: true)

        let gv = graph.graphviz(name: "Foo")
        XCTAssertEqual(gv.description, "digraph Foo { \"A\" -> \"B\"; \"B\" -> \"C\"; \"C\" -> \"A\" }")
    }
}
