import Foundation

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

public func >> (lhs: Node, rhs: Node) -> Edge {
    return Edge(from: lhs, to: rhs)
}

public struct Edge {
    public var from: Node
    public var to: Node
}

extension Edge: Statement {
    public func serialize(with context: Graphviz) -> String {
        return "\"\(from.identifier)\" \(context.type.edgeOperator) \"\(to.identifier)\""
    }
}
