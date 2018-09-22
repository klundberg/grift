//
//  DependenciesCommand.swift
//  Grift
//
//  Created by Kevin Lundberg on 3/23/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import Commandant
import GriftKit
import Result
import SourceKittenFramework
import SwiftGraph
import Curry

struct GriftError: Error, CustomStringConvertible {
    var message: String

    var description: String {
        return message
    }
}

struct DependenciesCommand: CommandProtocol {

    let verb: String = "dependencies"
    let function: String = "Generates a dependency graph from swift files in the given directory"

    func run(_ options: DependenciesOptions) -> Result<(), GriftError> {
        do {
//            let structures = try GriftKit.structures(at: options.path)
//            let graph = GraphBuilder.build(structures: structures)
            let files = try GriftKit.files(at: options.path)
            let graph = GraphBuilder.build(files: files, compilerLogPath: options.compilerLogPath)
            let dot = graph.graphviz()
            print(dot.description)

            return .success(())
        } catch {
            return .failure(GriftError(message: "\(error)"))
        }
    }
}

struct DependenciesOptions: OptionsProtocol {
    let path: String
    let compilerLogPath: String

    static func evaluate(_ m: CommandMode) -> Result<DependenciesOptions, CommandantError<GriftError>> {
        return curry(DependenciesOptions.init)
            <*> m <| Option(key: "path", defaultValue: ".", usage: "The path to generate a dependency graph from")
            <*> m <| Option(key: "logPath", defaultValue: "", usage: "The path to pull compiler logs from")
        
    }
}
