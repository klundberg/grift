import Foundation
import Graphviz
import SourceKittenFramework

extension Graphviz {
    init(structures: [Structure]) {
        self.init(type: .directed, statements: structures.flatMap({ Graphviz.createStatements(dict: $0.dictionary) }))
    }

    private static func createStatements(dict: [String: SourceKitRepresentable], name: String = "") -> [Statement] {

        var statements: [Statement] = []
        var name = name

        if let typeName = dict[.typeName] as? String, !name.isEmpty {
            statements.append(Node(name) >> Node(typeName))
        }

        if let newName = dict[.name] as? String, kindIsEnclosingType(kind: dict[.kind]) {
            name = newName
        }

        if let substructures = dict[.substructure] as? [SourceKitRepresentable] {
            for substructure in substructures {
                if let substructureDict = substructure as? [String: SourceKitRepresentable] {
                    statements.append(contentsOf: createStatements(dict: substructureDict, name: name))
                }
            }
        }

        return statements
    }
}
