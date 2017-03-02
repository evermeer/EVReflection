//
//  EVReflectionCustomConverterTests.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 02/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionCustomConverterTests: XCTestCase {
    
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
    
    func testEnumWrapper() {
        let obj = TheObject()
        print("obj = \(obj)")
        let dict = obj.toDictionary()
        XCTAssert(dict["myval"] as? String ?? "" == "secondValue", "Should be converted to secondValue")
        XCTAssert(dict["otherVal"] as? String ?? "" == "third", "Should be converted to secondValue")
        let json = obj.toJsonString()
        print("json = \(json)")
        XCTAssert(json == "{\"myval\":\"secondValue\",\"otherVal\":\"third\"}")
    }
}


class TheObject: EVObject {
    var myval = SomeEnum(MyEnum.secondValue)
    var otherVal = SomeEnum(OtherEnum.third)
    
}

class SomeEnum: EVObject {
    var theEnum: EVRaw?
    
    convenience init(_ value: EVRaw) {
        self.init()
        self.theEnum = value
    }
    
    override func customConverter() -> AnyObject? {
        return theEnum?.anyRawValue as AnyObject?
    }
}

enum MyEnum: String, EVRaw {
    case firstValue
    case secondValue
    case thirdValue
}
enum OtherEnum: String, EVRaw {
    case first
    case second
    case third
}
