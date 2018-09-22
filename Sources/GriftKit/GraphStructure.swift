import Foundation
import SourceKittenFramework
import Graphviz

private func filesInDirectory(at path: String, using fileManager: FileManager = .default) throws -> [String] {

    guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil) else {
        return [] // TODO: throw error
    }

    return enumerator.compactMap({
        guard let url = $0 as? URL,
            !url.pathComponents.contains(".build"),
            !url.pathComponents.contains("Carthage"),
            url.pathExtension == "swift" else {
                return nil
        }

        return url.relativePath
    })

//    let contents = try fileManager.contentsOfDirectory(atPath: path)
//
//    return contents.flatMap({ (filename: String) -> String? in
//        guard filename.hasSuffix(".swift") else {
//            return nil
//        }
//
//        return (path as NSString).appendingPathComponent(filename)
//
//    })
}

public func syntaxMaps(for code: String) throws -> [SyntaxMap] {
    return try [SyntaxMap(file: File(contents: code))]
}

public func docs(for code: String) -> [SwiftDocs] {
    return SwiftDocs(file: File(contents: code), arguments: []).map({ [$0] }) ?? []
}

public func files(at path: String, using fileManager: FileManager = .default) throws -> [File] {
    return try filesInDirectory(at: path, using: fileManager).compactMap(File.init(path:))
}

public func structures(at path: String, using fileManager: FileManager = .default) throws -> [Structure] {
    let filePaths = try filesInDirectory(at: path, using: fileManager)

    return try filePaths.compactMap({ try structure(forFile: $0) })
}

func structures(for code: String) throws -> [Structure] {
    return try [Structure(file: File(contents: code))]
}

public func structure(forFile path: String) throws -> Structure? {
    guard let file = File(path: path) else {
        return nil
    }
    return try Structure(file: file)
}

extension Dictionary {
    subscript (keyEnum: SwiftDocKey) -> Value? {
        guard let key = keyEnum.rawValue as? Key else {
            return nil
        }
        return self[key]
    }
}

func kindIsEnclosingType(kind: SourceKitRepresentable?) -> Bool {
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
