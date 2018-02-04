import Foundation
@testable import GriftKit
import SourceKittenFramework
import SwiftGraph
import XCTest

class GriftKitTests: XCTestCase {

//    func testFolderGivesStructureArrayOfAllFilesInIt() {
//
//        var path = "./example.swift.test"
//        let thing = try! structure(forFile: path)
//        print(thing)
//
//        var args = ["-sdk",
//                    "/Applications/Xcode-9.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk",
//                    "-module-name",
//                    "Blah",
//                    "-c",
//                    path]
//
//        let cursorInfo = try! Request.cursorInfo(file: path, offset: 489, arguments: args).send()
//        print(cursorInfo)
//
////         {
////         "key.kind" : "source.lang.swift.expr.call",
////         "key.offset" : 489,
////         "key.nameoffset" : 489,
////         "key.namelength" : 5,
////         "key.bodyoffset" : 495,
////         "key.bodylength" : 0,
////         "key.length" : 7,
////         "key.name" : "thing"
////         }
//        args = ["-sdk",
//                    "/Applications/Xcode-8.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk",
//                    "-module-name",
//                    "Blah",
//                    "-c",
//                    path]
////        args += files
//
//        let index = Request.index(
//            file: path,
//            arguments:args)
//        try! print(toJSON(index.send()))
//    }

    private func buildGraph(for code: String) throws -> UnweightedGraph<Vertex> {
        return try GraphBuilder.build(structures: structures(for: code))
//        return GraphBuilder.build(docs: docs(for: code))
//        return GraphBuilder.build(syntax: syntaxMaps(for: code))
    }

    func testSingleStructWithNoFieldsCreatesSingleVertexGraph() throws {
        let code = "struct Thing { }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 1)
        XCTAssertEqual(graph.edgeCount, 0)
        XCTAssertTrue(graph.vertexInGraph(vertex: "Thing"))
    }

    func testSingleStructSwiftCodeCreatesOneEdgeGraph() throws {
        let code = "struct Thing { var x: String }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testTwoStructSwiftCodeCreatesTwoEdgeGraphGraph() throws {
        let code = "struct Thing { var x: String }; struct Foo { var bar: Int }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 4)
        XCTAssertEqual(graph.edgeCount, 2)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
        XCTAssertTrue(graph.edgeExists(from: "Foo", to: "Int"))
    }

    func testNestedStructSwiftCodeCreatesExpectedGraph() throws {
        let code = "struct Thing { struct Foo {} var x: Foo }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Foo"))
    }

    func testMoreComplexNestedStructSwiftCodeCreatesExpectedGraph() throws {
        let code = "struct Thing { struct Foo { let s: Int } var x: Foo }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Foo"))
        XCTAssertTrue(graph.edgeExists(from: "Foo", to: "Int"))
    }

    func testStructWithFunctionParametersShowsParametersProperly() throws {
        let code = "struct Thing { func foo(d: Double) { } }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testClassWithFunctionParametersShowsParametersProperly() throws {
        let code = "class Thing { func foo(d: Double) { } }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testEnumWithFunctionParametersShowsParametersProperly() throws {
        let code = "enum Thing { func foo(d: Double) { } }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testProtocolWithFunctionParametersShowsParametersProperly() throws {
        let code = "protocol Thing { func foo(d: Double) }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
    }

    func testTwoReferencesToTheSameTypeOnlyYieldOneEdge() throws {
        let code = "struct Thing { var x: String; var y: String }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 2)
        XCTAssertEqual(graph.edgeCount, 1)
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testThatGenericTypesPointToBothTypeAndGenericTypeParameter() throws {
        let code = "struct Thing { var x: Array<String> }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Array"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testArrayTypesAreNormalizedToNotHaveBrackets() throws {
        let code = "struct Thing { var x: [String] }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 3)
        XCTAssertEqual(graph.edgeCount, 2)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Array"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
    }

    func testThatGenericTypesWithMultipleGenericParamsPointToEachParameter() throws {
        let code = "struct Thing { var x: Dictionary<String, Int> }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 4)
        XCTAssertEqual(graph.edgeCount, 3)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Dictionary"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Int"))
    }

    func testThatDictionaryTypesAreNormalizedToNotHaveBracketsOrColons() throws {
        let code = "struct Thing { var x: [String: Int] }"

        let graph = try buildGraph(for: code)

        XCTAssertEqual(graph.vertexCount, 4)
        XCTAssertEqual(graph.edgeCount, 3)

        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Dictionary"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "String"))
        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Int"))
    }

//    func testStructWithFunctionShowsFunctionReturnTypeProperly() throws {
//        let code = "struct Thing { func foo() -> Double { return 0 } }"
//
//        let graph = try buildGraph(for: code)
//
//        XCTAssertEqual(graph.vertexCount, 2)
//        XCTAssertEqual(graph.edgeCount, 1)
//        XCTAssertTrue(graph.edgeExists(from: "Thing", to: "Double"))
//    }
}
