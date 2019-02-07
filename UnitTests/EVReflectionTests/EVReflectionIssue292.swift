//
//  EVReflectionIssue292.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 20-10-18.
//  Copyright © 2018 evict. All rights reserved.
//

import Foundation
import XCTest
import EVReflection

class TestIssue292: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Test292.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIssue292() {
        let tst = Test292()
        let json = tst.toJsonString()
        print("json = \(json)")
        let newTst = Test292(json: json)
        XCTAssertEqual(tst, newTst, "Should have been the same")
    }
}

var shouldFakeApi = true

public class Test292 : EVObject {
    var firstName: String?
    required public init() {
        if shouldFakeApi { firstName = "ConfigFirstName"}
    }
}
