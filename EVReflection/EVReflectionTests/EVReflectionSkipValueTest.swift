//
//  EVReflectionSkipValueTest.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 4/27/16.
//  Copyright © 2016 evict. All rights reserved.
//



import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionSkipValueTest: XCTestCase {
    
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
    func testTypeDict() {
        let a = TestObjectSkipValues()
        a.value1 = "test1"
        a.value2 = ""
        a.value4 = 4
        a.value6 = [String]()
        a.value6?.append("arrayElement")
        a.value7 = [String]()
        let json = a.toJsonString()
        print("json = \(json)")
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
        if let value = value as? String where value.characters.count == 0 {
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
}
