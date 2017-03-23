
import Foundation

protocol Statement {
    func serialize(with context: Graphviz) -> String
}

extension Sequence where Iterator.Element == Statement {
    func serialize(with context: Graphviz) -> String {
        return self.map({ $0.serialize(with: context) }).joined(separator: "; ")
    }
}

struct Graphviz {
    enum DirectionType: String {
        case undirected = "graph"
        case directed = "digraph"

        var edgeOperator: String {
            switch self {
            case .undirected: return "--"
            case .directed: return "->"
            }
        }
    }

    var type: DirectionType
    var name: String
    var statements: [Statement]

    init(type: DirectionType = .undirected, name: String = "", statements: [Statement] = []) {
        self.type = type
        self.name = name
        self.statements = statements
    }

    func serialize() -> String {
        return "\(type.rawValue) \(name) { \(statements.serialize(with: self)) }".removingRepeatedWhitespace()
    }
}

extension Graphviz: CustomStringConvertible {
    var description: String {
        return serialize()
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

struct Node {
    var identifier: String

    init(_ identifier: String) {
        self.identifier = identifier
    }
}

extension Node: Statement {
    func serialize(with context: Graphviz) -> String {
        return identifier
    }
}

extension Node: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }

    init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(String(value))
    }

    init(extendedGraphemeClusterLiteral value: Character) {
        self.init(String(value))
    }
}

struct Edge {
    var from: Node
    var to: Node
}

func >> (lhs: Node, rhs: Node) -> Edge {
    return Edge(from: lhs, to: rhs)
}

extension Edge: Statement {
    func serialize(with context: Graphviz) -> String {
        return "\(from.identifier) \(context.type.edgeOperator) \(to.identifier)"
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
