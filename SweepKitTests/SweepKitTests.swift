
import XCTest
import Foundation
import SourceKittenFramework
@testable import SweepKit

class SwiftGraphKitTests: XCTestCase {
    
    func testFolderGivesStructureArrayOfAllFilesInIt() {

        let path = "/Users/kevlar/workspaces/sweep/SweepKit/TestFile.swift"
//        let things = [structure(forFile: path)]
//        print(things[0]!)
        let thing = structure(forFile: path)
        print(thing)

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

        let thing = Graph(structures: structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> String }")
    }

    func testTwoStructSwiftCodeCreatesTwoEdgeGraphGraph() {
        let code = "struct Thing { var x: String }; struct Foo { var bar: Int }"

        let thing = Graph(structures: structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> String; Foo -> Int }")
    }

    func testNestedStructSwiftCodeCreatesExpectedGraph() {
        let code = "struct Thing { struct Foo {} var x: Foo }"

        let thing = Graph(structures: structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> Foo }")
    }

    func testMoreComplexNestedStructSwiftCodeCreatesExpectedGraph() {
        let code = "struct Thing { struct Foo { let s: Int } var x: Foo }"

        let thing = Graph(structures: structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Foo -> Int; Thing -> Foo }")
    }

    func testStructWithFunctionParametersShowsParametersProperly() {
        let code = "struct Thing { func foo(d: Double) { } }"

        let thing = Graph(structures: structures(for: code))

        XCTAssertEqual(thing.serialize(), "digraph { Thing -> Double }")
    }

//    func testStructWithFunctionShowsFunctionReturnTypeProperly() {
//        let code = "struct Thing { func foo() -> Double { return 0 } }"
//
//        let thing = Graph(structures: structures(for: code))
//
//        XCTAssertEqual(thing.serialize(), "digraph { Thing -> Double }")
//    }

}
