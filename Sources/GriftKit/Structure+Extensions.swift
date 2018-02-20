//import SourceKittenFramework
//
//extension Structure {
//    var subStructures: [SubStructure]? {
//        guard let substructures = dictionary[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] else {
//            return nil
//        }
//        return substructures.flatMap({
//            guard let structure = $0 as? [String: SourceKitRepresentable] else {
//                return nil
//            }
//            return SubStructure(dictionary: structure)
//        })
//    }
//}
//
//struct SubStructure {
//    enum Kind: String {
//        case `class` = "source.lang.swift.decl.class"
//        case `struct` = "source.lang.swift.decl.struct"
//        case `enum` = "source.lang.swift.decl.enum"
//    }
//
//    enum Accessibility: String {
//        case `public` = "source.lang.swift.accessibility.public"
//        case `internal` = "source.lang.swift.accessibility.internal"
//        case `private` = "source.lang.swift.accessibility.private"
//    }
//
//    var kind: Kind
//    var accessibility: Accessibility
//    var inheritedTypeNames: [String]
//    var referencedTypes: [String] = []
//
//    init(dictionary: [String: SourceKitRepresentable]) {
//        self.kind = Kind(rawValue: dictionary[SwiftDocKey.kind.rawValue] as! String)!
//        self.accessibility = Accessibility(rawValue: dictionary["key.accessibility"] as! String)!
//        let types = dictionary[SwiftDocKey.inheritedtypes.rawValue] as! [SourceKitRepresentable]
//        self.inheritedTypeNames = types.map({
//            $0 as! [String: SourceKitRepresentable]
//        }).map({
//            $0[SwiftDocKey.name.rawValue] as! String
//        })
//    }
//
//}

