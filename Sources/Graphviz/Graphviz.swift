import Foundation
import SwiftGraph

public struct Graphviz {
    public enum DirectionType: String {
        case undirected = "graph"
        case directed = "digraph"

        public var edgeOperator: String {
            switch self {
            case .undirected: return "--"
            case .directed: return "->"
            }
        }
    }

    var type: DirectionType
    var name: String
    var statements: [Statement]

    public init(type: DirectionType = .undirected, name: String = "", statements: [Statement] = []) {
        self.type = type
        self.name = name
        self.statements = statements
    }

    public func serialize() -> String {
        return "\(type.rawValue) \(name) { \(statements.serialize(with: self)) }".removingRepeatedWhitespace()
    }
}

extension Graphviz: CustomStringConvertible {
    public var description: String {
        return serialize()
    }
}

public protocol Statement {
    func serialize(with context: Graphviz) -> String
}

extension Sequence where Iterator.Element == Statement {
    func serialize(with context: Graphviz) -> String {
        return self.map({ $0.serialize(with: context) }).joined(separator: "; ")
    }
}


struct Subgraph {
    var identifier: String
    var statements: [Statement]

    init(_ identifier: String = "", isCluster: Bool = false, statements: [Statement] = []) {
        self.identifier = isCluster ? "cluster_\(identifier)" : identifier
        self.statements = statements
    }
}

extension Subgraph: Statement {
    func serialize(with context: Graphviz) -> String {
        return "subgraph \(identifier) { \(statements.serialize(with: context)) }"
    }
}

public struct Node {
    public var identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }
}

extension Node: Statement {
    public func serialize(with context: Graphviz) -> String {
        return "\"\(identifier)\""
    }
}

extension Node: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(String(value))
    }

    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(String(value))
    }
}

public struct Edge {
    public var from: Node
    public var to: Node
}

public func >> (lhs: Node, rhs: Node) -> Edge {
    return Edge(from: lhs, to: rhs)
}

extension Edge: Statement {
    public func serialize(with context: Graphviz) -> String {
        return "\"\(from.identifier)\" \(context.type.edgeOperator) \"\(to.identifier)\""
    }
}

extension String {
    func removingRepeatedWhitespace() -> String {
        return self.replacingOccurrences(of: "\\s+",
                                         with: " ",
                                         options: .regularExpression,
                                         range: self.startIndex..<self.endIndex)
    }
}

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
