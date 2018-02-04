import Foundation
import SourceKittenFramework
import SwiftGraph
import Graphviz

public typealias Vertex = String

public struct GraphBuilder {

    private var structures: [Structure]
    private var graph = UnweightedGraph<Vertex>()

    public init(structures: [Structure]) {
        self.structures = structures
    }

    public func build() -> UnweightedGraph<Vertex> {
        for structure in structures {
            populateGraph(from: structure.dictionary)
        }
        return graph
    }

    private func populateGraph(from dict: [String: SourceKitRepresentable], forVertexNamed name: String = "") {

        var name = name

        if let typeName = dict[.typeName] as? String, !name.isEmpty {

            let normalizedTypeName = normalize(typeWithName: typeName)

            let singleTypeNames = splitSingleTypeNames(fromComposedTypeName: normalizedTypeName)
            for singleTypeName in singleTypeNames {
                graph.addVertextIfNotPresent(singleTypeName)
                graph.addEdgeIfNotPresent(from: name, to: singleTypeName, directed: true)
            }
        }

        if let newName = dict[.name] as? String, kindIsEnclosingType(kind: dict[.kind]) {
            name = newName
            graph.addVertextIfNotPresent(name)
        }

        if let substructures = dict[.substructure] as? [SourceKitRepresentable] {
            for case let substructureDict as [String: SourceKitRepresentable] in substructures {
                populateGraph(from: substructureDict, forVertexNamed: name)
            }
        }
    }

    private func normalize(typeWithName name: String) -> String {
        let dictionarShorthandRegex = try! NSRegularExpression(pattern: "\\[\\s*(.+)\\s*:\\s*(.+)\\s*]", options: [])

        let dictionaryNormalizedTypeName = dictionarShorthandRegex.stringByReplacingMatches(in: name,
                                                                                            options: [],
                                                                                            range: NSRange(location: 0, length: (name as NSString).length), withTemplate: "Dictionary<$1,$2>")

        let arrayShorthandRegex = try! NSRegularExpression(pattern: "\\[(.+)\\]", options: [])

        return arrayShorthandRegex.stringByReplacingMatches(in: dictionaryNormalizedTypeName,
                                                            options: [],
                                                            range: NSRange(location: 0, length: (dictionaryNormalizedTypeName as NSString).length),
                                                            withTemplate: "Array<$1>")
    }

    private func splitSingleTypeNames(fromComposedTypeName name: String) -> [String] {
        let separatorCharacters = CharacterSet(charactersIn: "><,")

        return name.unicodeScalars.split(whereSeparator: {
            return separatorCharacters.contains($0)
        }).map({ String($0).trimmingCharacters(in: CharacterSet.whitespaces) })
    }

    private func kindIsEnclosingType(kind: SourceKitRepresentable?) -> Bool {
        guard let kind = kind as? String,
            let declarationKind = SwiftDeclarationKind(rawValue: kind) else {
                return false
        }

        switch declarationKind {
        case .`struct`, .`class`, .`enum`, .`protocol`:
            return true
        default:
            return false
        }
    }
}
