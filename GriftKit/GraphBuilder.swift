//
//  GraphBuilder.swift
//  Grift
//
//  Created by Kevin Lundberg on 3/22/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import Foundation
import SourceKittenFramework
import SwiftGraph

public typealias Vertex = String

public struct GraphBuilder {

    private var structures: [Structure]
    private var graph = UnweightedGraph<Vertex>()

    init(structures: [Structure]) {
        self.structures = structures
    }

    public func build() -> UnweightedGraph<Vertex> {
        for structure in structures {
            populateGraph(dict: structure.dictionary)
        }
        return graph
    }

    public func populateGraph(dict: [String: SourceKitRepresentable], forVertexNamed name: String = "") {

        var name = name

        if let typeName = dict[.typeName] as? String, !name.isEmpty {

            if !graph.vertexInGraph(vertex: typeName) {
                _ = graph.addVertex(typeName)
            }
            graph.addEdge(from: name, to: typeName, directed: true)
        }

        if let newName = dict[.name] as? String, kindIsEnclosingType(kind: dict[.kind]) {
            name = newName

            if !graph.vertexInGraph(vertex: name) {
                _ = graph.addVertex(name)
            }
        }

        if let substructures = dict[.substructure] as? [SourceKitRepresentable] {
            for case let substructureDict as [String: SourceKitRepresentable] in substructures {
                populateGraph(dict: substructureDict, forVertexNamed: name)
            }
        }
    }
    
    private func kindIsEnclosingType(kind: SourceKitRepresentable?) -> Bool {
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

}
