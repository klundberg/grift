import Foundation
import SourceKittenFramework

func extractTypes(from file: File) throws -> [String] {
    let map = try SyntaxMap(file: file)
    var names: [String] = []
    for token in map.tokens where token.type == SyntaxKind.typeidentifier.rawValue {
        let startIndex = file.contents.index(file.contents.startIndex, offsetBy: token.offset)
        let endIndex = file.contents.index(startIndex, offsetBy: token.length)

        names.append(String(file.contents[startIndex..<endIndex]))
    }
    return names
}
