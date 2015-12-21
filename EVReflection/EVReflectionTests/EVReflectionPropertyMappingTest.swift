//
//  EVReflectionPropertyMappingTest.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/24/15.
//  Copyright © 2015 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionPropertyMappingTests: XCTestCase {
    func testCustomPropertyMapping() {
        let dict = ["Name":"just a field", "dummyKeyInJson":"will be ignored", "keyInJson":"value for propertyInObject", "ignoredProperty":"will not be read or written"]
        let a = TestObject5(dictionary: dict)
        XCTAssertEqual(a.Name, "just a field", "Name should containt 'just a field'")
        XCTAssertEqual(a.propertyInObject, "value for propertyInObject", "propertyInObject should containt 'value for propertyInObject'")
        XCTAssertEqual(a.ignoredProperty, "", "ignoredProperty should containt ''")
        
        let toDict = a.toDictionary(true)
        let dict2 = ["name":"just a field","key_in_json":"value for propertyInObject"]
        XCTAssertEqual(toDict, dict2, "export dictionary should only contain a name and key_in_json")
    }
    
    func testCamelCaseToUndersocerMapping() {
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("swiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("SwiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        
    }
    
    
    func testCustomPropertyConverter() {
        let json = "{\"is_great\":\"Sure\"}"
        let t = TestObject6(json: json)
        XCTAssertTrue(t.isGreat, "This mapping should make true from 'Sure'")
        let s = t.toJsonString()
        XCTAssertEqual(s, "{\n  \"isGreat\" : \"Sure\"\n}", "The json should contain 'Sure'")
        t.isGreat = false
        let s2 = t.toJsonString(true)
        XCTAssertEqual(s2, "{\n  \"is_great\" : \"Nah\"\n}", "The json should contain 'Nah'")
    }
}