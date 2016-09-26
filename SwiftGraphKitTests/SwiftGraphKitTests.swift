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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFolderGivesStructureArrayOfAllFilesInIt() {
        let path = ("~/workspaces/SwiftGraph/SwiftGraphKitTests" as NSString).stringByExpandingTildeInPath
        
        let list = structures(at: path)
        print(list)

//        XCTAssertEqual(list.count, 1)
    }
    
}
