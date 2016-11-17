//
//  SwiftGraphKitTests.swift
//  SwiftGraphKitTests
//
//  Created by Kevin Lundberg on 9/23/16.
//  Copyright © 2016 Kevin Lundberg. All rights reserved.
//

import XCTest
import Foundation
import SourceKittenFramework
@testable import SwiftGraphKit

class SwiftGraphKitTests: XCTestCase {
    
    func testFolderGivesStructureArrayOfAllFilesInIt() {

//        let dir = ("~/workspaces/SwiftGraph/SwiftGraphKitTests" as NSString).stringByExpandingTildeInPath

//        let files = filesInDirectory(at: dir)

//        let list = structures(at: dir)

//        let data = (list.description as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//        try! data?.writeToFile("\(dir)/json.json", options: .DataWritingAtomic)

//        print(list.map({
//            $0.subStructures
//        }))
//        XCTAssertEqual(list.count, 1)

        let path = "/Users/kevlar/workspaces/SwiftGraph/SwiftGraphKit/TestFile.swift"
        let things = [structure(forFile: path)]
//        let thing = things.flatMap({ $0 }).map({ thing in graph([thing]) })
//
        print(things[0])

        let args = ["-sdk",
                    "/Applications/Xcode-8.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk",
                    "-module-name",
                    "Blah",
                    "-c",
                    path]
// 489

        let cursorInfo = Request.cursorInfo(file: path, offset: 489, arguments: args).send()
        print(cursorInfo)

/*

         {
         "key.kind" : "source.lang.swift.expr.call",
         "key.offset" : 489,
         "key.nameoffset" : 489,
         "key.namelength" : 5,
         "key.bodyoffset" : 495,
         "key.bodylength" : 0,
         "key.length" : 7,
         "key.name" : "thing"
         }
 */

//        let path = files.first!
//        var args = ["-sdk",
//                    "/Applications/Xcode-8.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk",
//                    "-module-name",
//                    "Blah",
//                    "-c",
//                    path]
//        args += files

//        let index = Request.Index(
//            file: path,
//            arguments:args)
//        print(toJSON(toAnyObject(index.send())))
    }

    func testSingleStructSwiftCodeCreatesOneEdgeGraph() {
        let code = "struct Thing { var x: String }"

        let thing = graph(structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> String }")
    }

    func testTwoStructSwiftCodeCreatesTwoEdgeGraphGraph() {
        let code = "struct Thing { var x: String }; struct Foo { var bar: Int }"

        let thing = graph(structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> String; Foo -> Int }")
    }

//    func testStructWithFunctionShowsFunctionReturnTypeProperly() {
//        let code = "struct Thing { func foo() -> Double { return 0 } }"
//
//        let thing = graph(structures(for: code))
//
//        XCTAssertEqual(thing.serialize(), "digraph { Thing -> Double }")
//    }

}
