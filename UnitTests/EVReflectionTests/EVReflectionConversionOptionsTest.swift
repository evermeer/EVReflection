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
        EVReflection.setBundleIdentifier(TestObject.self)
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
        print("All available conversion options are: \(ConversionOptions.All.description)")
        let a = TestObjectSkipValues()
        a.value1 = "test1"
        a.value2 = ""
        a.value4 = 4
        a.value6 = [String]()
        a.value6?.append("arrayElement")
        a.value7 = [String]()
        let json = a.toJsonString()
        print("json = \(json)")
        
        XCTAssertEqual(json,"{\"value4\":4,\"value1\":\"test1\",\"value6\":[\"arrayElement\"]}", "Incorrect json")
        let json2 = a.toJsonString(.None)
        print("json = \(json2)")
        XCTAssertEqual(json2, "{\"value1\":\"test1\",\"value5\":null,\"value2\":\"\",\"value6\":[\"arrayElement\"],\"value3\":null,\"value7\":[],\"value4\":4,\"value8\":null}", "Incorrect json")
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
    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.characters.count == 0 || value == "null" {
            print("Ignoring empty string for key \(key)")
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            print("Ignoring empty NSArray for key\(key)")
            return true
        } else if value is NSNull {
            print("Ignoring NSNull for key \(key)")
            return true
        }
        return false
    }
    
    // Handling the setting of non key-value coding compliant properties
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
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
