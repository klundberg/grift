import Foundation
import SourceKittenFramework
import SwiftGraph
import Graphviz

public typealias Vertex = String

struct CompilerArgumentsExtractor {
    static func allCompilerInvocations(compilerLogs: String) -> [String] {
        var compilerInvocations = [String]()
        compilerLogs.enumerateLines { line, _ in
            if let swiftcIndex = line.range(of: "swiftc ")?.upperBound, line.contains(" -module-name ") {
                compilerInvocations.append(String(line[swiftcIndex...]))
            }
        }
        
        return compilerInvocations
    }
    
    static func compilerArgumentsForFile(_ sourceFile: String, compilerInvocations: [String]) -> [String]? {
        let escapedSourceFile = sourceFile.replacingOccurrences(of: " ", with: "\\ ")
        guard let compilerInvocation = compilerInvocations.first(where: { $0.contains(escapedSourceFile) }) else {
            return nil
        }
        
        return parseCLIArguments(compilerInvocation)
    }
    
    private static func parseCLIArguments(_ string: String) -> [String] {
        let escapedSpacePlaceholder = "\u{0}"
        let scanner = Scanner(string: string)
        var str = ""
        var didStart = false
        var result: NSString?
        while scanner.scanUpTo("\"", into: &result), let result = result as String? {
            if didStart {
                str += result.replacingOccurrences(of: " ", with: escapedSpacePlaceholder)
                str += " "
            } else {
                str += result
            }
            _ = scanner.scanString("\"", into: nil)
            didStart = !didStart
        }
        return filter(arguments:
            str.trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "\\ ", with: escapedSpacePlaceholder)
                .components(separatedBy: " ")
                .map { $0.replacingOccurrences(of: escapedSpacePlaceholder, with: " ") }
        )
    }
    
    private static func partiallyFilter(arguments args: [String]) -> ([String], Bool) {
        guard let indexOfFlagToRemove = args.index(of: "-output-file-map") else {
            return (args, false)
        }
        var args = args
        args.remove(at: args.index(after: indexOfFlagToRemove))
        args.remove(at: indexOfFlagToRemove)
        return (args, true)
    }
    
    private static func filter(arguments args: [String]) -> [String] {
        var args = args
        args.append(contentsOf: ["-D", "DEBUG"])
        var shouldContinueToFilterArguments = true
        while shouldContinueToFilterArguments {
            (args, shouldContinueToFilterArguments) = partiallyFilter(arguments: args)
        }
        return args.filter {
            ![
                "-parseable-output",
                "-incremental",
                "-serialize-diagnostics",
                "-emit-dependencies"
                ].contains($0)
            }.map {
                if $0 == "-O" {
                    return "-Onone"
                } else if $0 == "-DNDEBUG=1" {
                    return "-DDEBUG=1"
                }
                return $0
        }
    }
}

public enum GraphBuilder {

    static func compilerLogContents(logPath: String) -> String? {
        if logPath.isEmpty {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: logPath),
            let logContents = String(data: data, encoding: .utf8) {
            return logContents
        }
        
        print("couldn't read log file at path '\(logPath)'")
        return nil
    }
    
    public static func build(files: [File], compilerLogPath: String) -> UnweightedGraph<Vertex> {
        let graph = UnweightedGraph<Vertex>()
        guard let logContents = compilerLogContents(logPath: compilerLogPath) else {
            return graph
        }
        let invocations = CompilerArgumentsExtractor.allCompilerInvocations(compilerLogs: logContents)
        
        
        let indexes = try! files
            .compactMap({ $0.path })
            .map({ try Request.index(file: $0,
                                 arguments: CompilerArgumentsExtractor.compilerArgumentsForFile($0, compilerInvocations: invocations) ?? []).send() })
        print(indexes.count)
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
