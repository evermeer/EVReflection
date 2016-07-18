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
        EVReflection.setBundleIdentifier(Encoding.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue91() {
        let json = " {\"provinces\": [ { \"name\": \"\u{5168}\u{90e8}\u{5730}\u{533a}\", \"id\":\"worldwide\"}, {\"name\": \"\u{5b89}\u{5fbd}\", \"id\": 262}, {\"name\": \"\u{5317}\u{4eac}\",\"id\": 264 } ]}"
        let obj = TagObject(json: json)
        print(obj)

        let obj1 = TagObject2(json: json)
        print(obj1)

        let json2 = " {\"values\": [ { \"name\": \"\u{5168}\u{90e8}\u{5730}\u{533a}\", \"id\":\"worldwide\"}, {\"name\": \"\u{5b89}\u{5fbd}\", \"id\": 262}, {\"name\": \"\u{5317}\u{4eac}\",\"id\": 264 } ]}"
        let obj2 = TagObject2(json: json2)
        print(obj2)

        
        let json3 = " {\"subTags\": [ { \"name\": \"\u{5168}\u{90e8}\u{5730}\u{533a}\", \"id\":\"worldwide\"}, {\"name\": \"\u{5b89}\u{5fbd}\", \"id\": 262}, {\"name\": \"\u{5317}\u{4eac}\",\"id\": 264 } ]}"
        let obj3 = TagObject2(json: json3)
        print(obj3)

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

class TagObject2: BaseObject {
    var subTagArray: [SimpleObject]?
    
    override func setValue(_ value: AnyObject!, forUndefinedKey key: String) {
        guard let dict = value as? [NSDictionary] else { return }
        switch key {
        case "provinces", "values", "subTags":
            subTagArray = [SimpleObject](dictionaryArray: dict)
        default:
            NSLog("WARNING: setValue for key '\(key)' should be handled.")
        }
    }
}
