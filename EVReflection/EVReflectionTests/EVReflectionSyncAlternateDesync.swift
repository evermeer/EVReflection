//
//  EVReflectionSyncAlternateDesync.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 2/29/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionSyncAlternateDesync: XCTestCase {
    
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
        let json = "{\"foo\": \"foobar\", \"arr\": [{\"id\": \"test\"}, {\"id\": \"test2\"}]}"
        let theZ = z(json: json)
        let json2 = theZ.toJsonString()
//TODO: Fix issue #48
//        XCTAssertEqual(json, json2, "myInt should contain 2")
    }
    
}

class y : EVObject {
    var id = "y id"
    var name = "some name"
    var price = 12.30
    var phone = "555-5555"
}

class z: EVObject {
    var foo: String? = "foo"
    var bar: String? = "bar"
    var arr: [y] = []
    
    override func propertyConverters() -> [(String?, (Any?) -> (), () -> Any?)] {
        return [
            ( "arr",
                { self.arr = $0 as! [y] },
                { return self.arr.map({$0.id}) }
            )
        ]
    }
}
