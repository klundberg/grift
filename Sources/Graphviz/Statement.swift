import Foundation

public protocol Statement {
    func serialize(with context: Graphviz) -> String
}

extension Sequence where Iterator.Element == Statement {
    public func serialize(with context: Graphviz) -> String {
        return self.map({ $0.serialize(with: context) }).joined(separator: "; ")
    }
}
