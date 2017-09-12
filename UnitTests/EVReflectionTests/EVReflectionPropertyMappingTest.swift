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
        NSLog("\n\n===>This will generate a warning because we ignore the dummyKeyInJson")
        let a = TestObject5(dictionary: dict as NSDictionary)
        XCTAssertEqual(a.Name, "just a field", "Name should containt 'just a field'")
        XCTAssertEqual(a.propertyInObject, "value for propertyInObject", "propertyInObject should containt 'value for propertyInObject'")
        XCTAssertEqual(a.ignoredProperty, "", "ignoredProperty should containt ''")
        
        let toDict = a.toDictionary([.DefaultSerialize, .KeyCleanup])
        let dict2 = ["name":"just a field","key_in_json":"value for propertyInObject"]
        XCTAssertEqual(toDict as! [String : String], dict2, "export dictionary should only contain a name and key_in_json")
    }
    
    func testCamelCaseToUndersocerMapping() {
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("swiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("SwiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        
    }
    
    
    func testCustomPropertyConverter() {
        let json = "{\"is_great\":\"Sure\"}"
        let t = TestObject6(json: json)
        XCTAssertTrue(t.isGreat, "This mapping should make true from 'Sure'")
        let s = t.toJsonString(.PropertyConverter) // So no PropertyMapping, SkipPropertyValue or KeyCleanup
        XCTAssertEqual(s, "{\"isGreat\":\"Sure\"}", "The json should contain 'Sure'")
        t.isGreat = false
        let s2 = t.toJsonString([.DefaultSerialize, .KeyCleanup])
        XCTAssertEqual(s2, "{\"is_great\":\"Nah\"}", "The json should contain 'Nah'")
    }
}


/**
 For testing the custom property maping
 */
open class TestObject5: EVObject {
    var Name: String = "" // Using the default mapping
    var propertyInObject: String = "" // will be written to or read from keyInJson
    var ignoredProperty: String = "" // Will not be written or read to/from json
    
    override open func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "ignoredProperty", keyInResource: nil),
                (keyInObject: nil, keyInResource: "ignoredProperty"),
                (keyInObject: "propertyInObject", keyInResource: "keyInJson")]
    }
}



/**
 For testing the custom property conversion
 */
open class TestObject6: EVObject {
    var isGreat: Bool = false
    
    override open func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [( // We want a custom converter for the field isGreat
            key: "isGreat",
            // isGreat will be true if the json says 'Sure'
            decodeConverter: { self.isGreat = ($0 as? String == "Sure") },
            // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
            encodeConverter: { return self.isGreat ? "Sure": "Nah"})]
    }
}

open class TestObject6child: EVObject {
    var seconOverride: String?
    override open func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [( // We want a custom converter for the field isGreat
            key: "seconOverride",
            decodeConverter: { self.seconOverride = ($0 as? String ?? "") },
            encodeConverter: { return self.seconOverride })] //.append(contentsOf: super.propertyConverters())
    }
}
