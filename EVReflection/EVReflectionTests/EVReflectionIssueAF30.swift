//
//  EVReflectionIssueAF30.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 24/09/2016.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation

import Foundation
import XCTest
@testable import EVReflection

class TestIssueAF30: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(MoreSection.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Testing unexpected results
    func testIssueAF30() {
        let json = "{" +
            "  \"username\": [" +
            "    \"some error.\"," +
            "    \"another error.\"" +
            "  ]," +
            "  \"email\": [" +
            "    \"some error.\"" +
            "  ]" +
            "}"
    
        print("--> You will now get 2 warnings about an array that is not an element.")
        let object = TestUser(json: json)
        print("\(object)")
    }
}

class TestUser: EVObject {
    var username: String?
    var email: String?
}
