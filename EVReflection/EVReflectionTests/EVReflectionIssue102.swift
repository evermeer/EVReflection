//
//  EVReflectionIssue102.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 7/8/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest
@testable import EVReflection

class TestIssue102: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Message)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue102() {
        let a = XTest(json: "{\"field1\":\"A\",\"field2\":\"true\"}")
        XCTAssert(a.field1 == "A")
        XCTAssert(a.field2 == true)

        let a2 = XTest(json: "{\"field1\":\"A\",\"field2\":true}")
        XCTAssert(a2.field1 == "A")
        XCTAssert(a2.field2 == true)

        let b = XTest(json: "{\"field1\":\"A\",\"field2\":\"yes\"}")
        XCTAssert(b.field1 == "A")
        XCTAssert(b.field2 == true)

        let c = XTest(json: "{\"field1\":\"A\",\"field2\":\"1\"}")
        XCTAssert(c.field1 == "A")
        XCTAssert(c.field2 == true)
        
        let d = XTest(json: "{\"field1\":\"A\",\"field2\":\"false\"}")
        XCTAssert(d.field1 == "A")
        XCTAssert(d.field2 == false)

        let d2 = XTest(json: "{\"field1\":\"A\",\"field2\":false}")
        XCTAssert(d2.field1 == "A")
        XCTAssert(d2.field2 == false)
        
        let e = XTest(json: "{\"field1\":\"A\",\"field2\":\"no\"}")
        XCTAssert(e.field1 == "A")
        XCTAssert(e.field2 == false)

        let f = XTest(json: "{\"field1\":\"A\",\"field2\":\"0\"}")
        XCTAssert(f.field1 == "A")
        XCTAssert(f.field2 == false)

        let g = XTest(json: "{\"field1\":\"A\",\"field2\":\"incorrect\"}")
        XCTAssert(g.field1 == "A")
        XCTAssert(g.field2 == false)

    }
}


class XTest: EVObject {
    var field1: String?
    var field2: Bool = false
}
