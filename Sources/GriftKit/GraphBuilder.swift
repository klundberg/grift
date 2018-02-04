import Foundation
import SourceKittenFramework
import SwiftGraph
import Graphviz

public typealias Vertex = String

public enum GraphBuilder {

    public static func build(files: [File]) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()

        return graph
    }

    public static func build(structures: [Structure]) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()
        for structure in structures {
            populate(graph: graph, from: structure.dictionary)
        }
        return graph
    }

    public static func build(docs: [SwiftDocs]) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()
        for doc in docs {
            populate(graph: graph, from: doc.docsDictionary)
        }
        return graph
    }

    private static func populate(graph: UnweightedGraph<Vertex>, from dict: [String: SourceKitRepresentable], forVertexNamed name: String = "") {

        var name = name

        if let typeName = dict[.typeName] as? String, !name.isEmpty {
            for singleTypeName in normalize(typeWithName: typeName) {
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
                populate(graph: graph, from: substructureDict, forVertexNamed: name)
            }
        }
    }

    private static func normalize(typeWithName name: String) -> [String] {
        let dictionarShorthandRegex = try! NSRegularExpression(pattern: "\\[\\s*(.+)\\s*:\\s*(.+)\\s*]", options: [])

        let dictionaryNormalizedTypeName = dictionarShorthandRegex.stringByReplacingMatches(in: name,
                                                                                            options: [],
                                                                                            range: NSRange(location: 0, length: (name as NSString).length), withTemplate: "Dictionary<$1,$2>")

        let arrayShorthandRegex = try! NSRegularExpression(pattern: "\\[(.+)\\]", options: [])

        let normalizedTypeName = arrayShorthandRegex.stringByReplacingMatches(in: dictionaryNormalizedTypeName,
                                                            options: [],
                                                            range: NSRange(location: 0, length: (dictionaryNormalizedTypeName as NSString).length),
                                                            withTemplate: "Array<$1>")

        return splitSingleTypeNames(fromComposedTypeName: normalizedTypeName)
    }

    private static func splitSingleTypeNames(fromComposedTypeName name: String) -> [String] {
        let separatorCharacters = CharacterSet(charactersIn: "><,")

        return name.unicodeScalars.split(whereSeparator: {
            return separatorCharacters.contains($0)
        }).map({ String($0).trimmingCharacters(in: CharacterSet.whitespaces) })
    }
}
