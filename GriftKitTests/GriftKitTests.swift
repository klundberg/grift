import Foundation
@testable import GriftKit
import SourceKittenFramework
import SwiftGraph
import XCTest

class GriftKitTests: XCTestCase {

//    func testFolderGivesStructureArrayOfAllFilesInIt() {
//
//        let path = "/Users/kevlar/workspaces/grift/GriftKit/TestFile.swift"
//        let thing = structure(forFile: path)
//        print(thing)
//
//        let args = ["-sdk",
//                    "/Applications/Xcode-8.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk",
//                    "-module-name",
//                    "Blah",
//                    "-c",
//                    path]
// 489

//        let cursorInfo = Request.cursorInfo(file: path, offset: 489, arguments: args).send()
//        print(cursorInfo)
//
//         {
//         "key.kind" : "source.lang.swift.expr.call",
//         "key.offset" : 489,
//         "key.nameoffset" : 489,
//         "key.namelength" : 5,
//         "key.bodyoffset" : 495,
//         "key.bodylength" : 0,
//         "key.length" : 7,
//         "key.name" : "thing"
//         }
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
//    }

    func testSingleStructWithNoFieldsCreatesSingleVertexGraph() {

        let code = "struct Thing { }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 1)
        XCTAssertEqual(graph.edgeCount, 0)
        XCTAssertTrue(graph.vertexInGraph(vertex: "Thing"))
    }

    func testSingleStructSwiftCodeCreatesOneEdgeGraph() {
        let code = "struct Thing { var x: String }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testTwoStructSwiftCodeCreatesTwoEdgeGraphGraph() {
        let code = "struct Thing { var x: String }; struct Foo { var bar: Int }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 4)
        XCTAssertEqual(graph.edgeCount, 2)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
        XCTAssertTrue(graph.edgeExists(from: "Foo", to: "Int"))
    }

    func testNestedStructSwiftCodeCreatesExpectedGraph() {
        let code = "struct Thing { struct Foo {} var x: Foo }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Foo"))
    }

    func testMoreComplexNestedStructSwiftCodeCreatesExpectedGraph() {
        let code = "struct Thing { struct Foo { let s: Int } var x: Foo }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Foo"))
        XCTAssertTrue(graph.edgeExists(from: "Foo", to: "Int"))
    }

    func testStructWithFunctionParametersShowsParametersProperly() {
        let code = "struct Thing { func foo(d: Double) { } }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testClassWithFunctionParametersShowsParametersProperly() {
        let code = "class Thing { func foo(d: Double) { } }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testEnumWithFunctionParametersShowsParametersProperly() {
        let code = "enum Thing { func foo(d: Double) { } }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testProtocolWithFunctionParametersShowsParametersProperly() {
        let code = "protocol Thing { func foo(d: Double) }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testTwoReferencesToTheSameTypeOnlyYieldOneEdge() {
        let code = "struct Thing { var x: String; var y: String }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testThatGenericTypesPointToBothTypeAndGenericTypeParameter() {
        let code = "struct Thing { var x: Array<String> }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Array"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testArrayTypesAreNormalizedToNotHaveBrackets() {
        let code = "struct Thing { var x: [String] }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Array"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testThatGenericTypesWithMultipleGenericParamsPointToEachParameter() {
        let code = "struct Thing { var x: Dictionary<String, Int> }"

        let graph = GraphBuilder(structures: structures(for: code)).build()

        XCTAssertEqual(graph.vertexCount, 4)
        XCTAssertEqual(graph.edgeCount, 3)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Dictionary"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Int"))
    }

//    func testStructWithFunctionShowsFunctionReturnTypeProperly() {
//        let code = "struct Thing { func foo() -> Double { return 0 } }"
//
//        let graph = GraphBuilder(structures: structures(for: code)).build()
//
//        XCTAssertEqual(graph.vertexCount, 2)
//        XCTAssertEqual(graph.edgeCount, 1)
//        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
//    }

}
