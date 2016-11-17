
import Foundation
import SourceKittenFramework

func filesInDirectory(at path: String, using fileManager: FileManager = .default) -> [String] {
    let contents = try! fileManager.contentsOfDirectory(atPath: path)

    return contents.flatMap({ (filename: String) -> String? in
        guard filename.hasSuffix(".swift") else {
            return nil
        }

        return (path as NSString).appendingPathComponent(filename)

    })
}

public func structures(at path: String, using fileManager: FileManager = .default) -> [Structure] {

    let filePaths = filesInDirectory(at: path, using: fileManager)

    return filePaths.flatMap({ structure(forFile: $0) })
}

public func structure(forFile path: String) -> Structure? {
    guard let file = File(path: path) else {
        return nil
    }
    return Structure(file: file)
}

//private protocol StringType {}
//extension String: StringType {}

extension Dictionary {
    subscript (keyEnum: SwiftDocKey) -> Value? {
        guard let key = keyEnum.rawValue as? Key else {
            return nil
        }
        return self[key]
    }
}

func graph(_ structures: [Structure]) -> Graph {
    var graph = Graph(type: .directed)

    var statements: [Statement] = []

    for structure in structures {
        let substructures = structure.dictionary[SwiftDocKey.substructure.rawValue] as! [SourceKitRepresentable]
        for substructure in substructures {
            let substructureThing = substructure as! [String: SourceKitRepresentable]

            let name = substructureThing[.name] as! String
            let subsubstructures = substructureThing[.substructure] as! [SourceKitRepresentable]
            for subsubstructure in subsubstructures {
                let subsubstructureThing = subsubstructure as! [String: SourceKitRepresentable]
                let typename = subsubstructureThing[.typeName] as! String

                statements.append(Node(name) >> Node(typename))
            }
        }
    }

    graph.statements = statements
    return graph
}

func structures(for code: String) -> [Structure] {
    return [Structure(file: File(contents: code))]
}
