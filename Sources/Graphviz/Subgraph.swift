import Foundation

public struct Subgraph {
    public var identifier: String
    public var statements: [Statement]

    public init(_ identifier: String = "", isCluster: Bool = false, statements: [Statement] = []) {
        self.identifier = isCluster ? "cluster_\(identifier)" : identifier
        self.statements = statements
    }
}

extension Subgraph: Statement {
    public func serialize(with context: Graphviz) -> String {
        return "subgraph \(identifier) { \(statements.serialize(with: context)) }"
    }
}
