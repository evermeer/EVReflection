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
        EVReflection.setBundleIdentifier(TestObject.self)
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

    func testNestedObjectsDeclaration() {
        let json = "{\"id\":\"anObjectOfClassA\", \"nestedClassProperty\": {\"id\": \"aSubObjectOfClassB\"}}"
        let a = Outer(json: json)
        print(a)
        XCTAssertEqual(a.nestedClassProperty?.id, "aSubObjectOfClassB", "Inner optional object should have been set.")
    }
}

open class A: EVObject {
    open var b = B()
    open var s = "test A"
    
    public required init() {
        super.init()
        b.intProp = 9
    }
}

open class B: EVObject {
    
    open var t = "test B"
    
    public required init() {
        super.init()
        intProp = 5
    }
    
    open var intProp = 0 {
        didSet {
            print("intProp set to \(intProp)")
        }
    }
    
    open override func propertyMapping() -> [(String?, String?)] {
        return [("intProp", nil)]
    }
}




class Outer: EVObject {
    class Inner: EVObject {
        var id: String = ""
    }
    
    var id: String = ""
    var nestedClassProperty: Inner? = Inner()
}
