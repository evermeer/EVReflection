//
//  EVReflectionNestedObjectsTest.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 2/3/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
@testable import EVReflection


/**
 Testing The serialize and deserialize when using object enheritance.
 */
class EVRelfectionNestedObjectsTests: XCTestCase {
    
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

    func testNestedObjectsInitializers() {
        let a = A()
        let dict = a.toDictionary()
        let newa = A(dictionary: dict)
        XCTAssertEqual(a, newa, "The objects should still be the same")
        XCTAssertEqual(newa.b.intProp, 9, "b.initProp should still be 9")
        print("json = \(newa.toJsonString())")
    }

}

public class A : EVObject {
    public var b = B()
    public var s = "test A"
    
    public required init() {
        super.init()
        b.intProp = 9
    }
}

public class B: EVObject {
    
    public var t = "test B"
    
    public required init() {
        super.init()
        intProp = 5
    }
    
    public var intProp = 0 {
        didSet {
            print("intProp set to \(intProp)")
        }
    }
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("intProp", nil)]
    }
}
