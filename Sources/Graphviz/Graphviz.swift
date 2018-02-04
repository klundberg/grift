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

extension String {
    func removingRepeatedWhitespace() -> String {
        return self.replacingOccurrences(of: "\\s+",
                                         with: " ",
                                         options: .regularExpression,
                                         range: self.startIndex..<self.endIndex)
    }
}
