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
    return Graph()
}
