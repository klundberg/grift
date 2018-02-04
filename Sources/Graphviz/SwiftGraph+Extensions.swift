import Foundation
import SwiftGraph

extension UnweightedGraph {
    public func addEdgeIfNotPresent(from source: T, to destination: T, directed: Bool) {
        if !edgeExists(from: source, to: destination) {
            addEdge(from: source, to: destination, directed: directed)
        }
    }
}

extension Graph {
    @discardableResult
    public func addVertextIfNotPresent(_ vertex: V) -> Int {
        return indexOfVertex(vertex) ?? addVertex(vertex)
    }

    public func graphviz(name: String = "") -> Graphviz {
        var statements = [Statement]()

        for from in self {
            for to in neighborsForVertex(from)! {
                let fromNode = String(describing: from)
                let toNode = String(describing: to)
                statements.append(Node(fromNode) >> Node(toNode))
            }
        }

        return Graphviz(type: .directed, name: name, statements: statements)
    }
}
