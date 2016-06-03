//
//  EVReflectionIssue91.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 6/3/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest

@testable import EVReflection


class TestIssue91: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Encoding)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue91() {
        let json = " {\"provinces\": [ { \"name\": \"\u{5168}\u{90e8}\u{5730}\u{533a}\", \"id\":\"worldwide\"}, {\"name\": \"\u{5b89}\u{5fbd}\", \"id\": 262}, {\"name\": \"\u{5317}\u{4eac}\",\"id\": 264 } ]}"

        let obj = TagObject(json: json)
        print(obj)
        
    }
}

class BaseObject: EVObject {
    
}

class SimpleObject: BaseObject {
    var name: String?
    var id: String?
}

class TagObject: BaseObject {
    
    var subTagArray: [SimpleObject]?
    
    override func propertyMapping() -> [(String?, String?)] {
        return [("subTagArray", "provinces")]
    }
}
