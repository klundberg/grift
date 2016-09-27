//
//  Something.swift
//  SwiftGraph
//
//  Created by Kevin Lundberg on 9/23/16.
//  Copyright © 2016 Kevin Lundberg. All rights reserved.
//

import Foundation
import SourceKittenFramework

public func structures(at path: String, using fileManager: NSFileManager = .defaultManager()) -> [Structure] {
    print(path)
    
    let contents = try! fileManager.contentsOfDirectoryAtPath(path)

    let files = contents.map({ (filename: String) -> File? in
        guard filename.hasSuffix(".swift") else {
            return nil
        }

        return File(path: (path as NSString).stringByAppendingPathComponent(filename))
    })

    return files.flatMap({
        $0.map(Structure.init)
    })
}

func graph(structures: [Structure]) -> Graph {
    var graph = Graph(type: .directed)


    var statements: [Statement] = []

    for structure in structures {
        let substructures = structure.dictionary[SwiftDocKey.Substructure.rawValue] as! [SourceKitRepresentable]
        for substructure in substructures {
            let substructureThing = substructure as! [String: SourceKitRepresentable]

            let name = substructureThing[SwiftDocKey.Name.rawValue] as! String
            let subsubstructures = substructureThing[SwiftDocKey.Substructure.rawValue] as! [SourceKitRepresentable]
            for subsubstructure in subsubstructures {
                let subsubstructureThing = subsubstructure as! [String: SourceKitRepresentable]
                let typename = subsubstructureThing[SwiftDocKey.TypeName.rawValue] as! String

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
