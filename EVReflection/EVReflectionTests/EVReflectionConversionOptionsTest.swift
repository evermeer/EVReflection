//
//  EVReflectionConversionOptionsTest.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 4/29/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionConversionOptionsTest: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    /**
     Test the conversion from string to number and from number to string
     */
    func testSkiptValues() {
        let a = TestObjectSkipValues()
        a.value1 = "test1"
        a.value2 = ""
        a.value4 = 4
        a.value6 = [String]()
        a.value6?.append("arrayElement")
        a.value7 = [String]()
        let json = a.toJsonString()
        print("json = \(json)")
        XCTAssertEqual(json, "{\n  \"value6\" : [\n    \"arrayElement\"\n  ],\n  \"value4\" : 4,\n  \"value1\" : \"test1\"\n}", "Incorrect json")
        let json2 = a.toJsonString(.None)
        print("json = \(json2)")
        XCTAssertEqual(json2, "{\n  \"value1\" : \"test1\",\n  \"value5\" : null,\n  \"value2\" : \"\",\n  \"value6\" : [\n    \"arrayElement\"\n  ],\n  \"value3\" : null,\n  \"value7\" : [\n\n  ],\n  \"value4\" : 4,\n  \"value8\" : null\n}", "Incorrect json")
        let b = TestObjectSkipValues(json: json2)
        let json3 = b.toJsonString()
        XCTAssertEqual(json, json3, "Json should be the same")        
    }
}

class TestObjectSkipValues: EVObject {
    var value1: String?
    var value2: String?
    var value3: String?
    var value4: Int?
    var value5: Int?
    var value6: [String]?
    var value7: [String]?
    var value8: [String]?
    
    // Put this in your own base class if you want to have this logic in all your classes
    override func skipPropertyValue(value: Any, key: String) -> Bool {
        if let value = value as? String where value.characters.count == 0 || value == "null" {
            print("Ignoring empty string for key \(key)")
            return true
        } else if let value = value as? NSArray where value.count == 0 {
            print("Ignoring empty NSArray for key\(key)")
            return true
        } else if value is NSNull {
            print("Ignoring NSNull for key \(key)")
            return true
        }
        return false
    }
    
    // Handling the setting of non key-value coding compliant properties
    override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "value4":
            value4 = value as? Int
        case "value5":
            value5 = value as? Int
        default:
            print("---> setValue for key '\(key)' should be handled.")
        }
    }
}
