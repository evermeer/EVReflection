//
//  EVRelfectionInheritanceTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/28/15.
//  Copyright © 2015 evict. All rights reserved.
//


import XCTest
@testable import EVReflection


/**
 Testing The serialize and deserialize when using object inheritance.
 */
class EVRelfectionInheritanceTests: XCTestCase {
    
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
    
    func testEnheritance() {
        // Build up the original object
        let quz = Quz()
        quz.fooBar = Bar()
        quz.fooBaz = Baz()
        quz.fooFoo = Foo()
        quz.fooArray = [Bar(), Baz(), Foo()]
        
        // The object JSON
        let json = quz.toJsonString()
        print("Original JSON = \(json)")
        
        // Deserialize a new object based on that JSON
        let newObject = Quz(json: json)
        
        XCTAssertEqual((newObject.fooBar as? Bar)?.justBar, "For bar only", "fooBar is not Bar?")
        XCTAssertEqual((newObject.fooBaz as? Baz)?.justBaz, "For baz only", "fooBaz is not Baz?")
        XCTAssertEqual(newObject.fooArray.count, 3, "array should contain 3 objects")
        if newObject.fooArray.count == 3 {
            XCTAssertEqual((newObject.fooArray[0] as? Bar)?.justBar, "For bar only", "fooBar is not Bar?")
            XCTAssertEqual((newObject.fooArray[1] as? Baz)?.justBaz, "For baz only", "fooBaz is not Baz?")
            XCTAssertEqual(newObject.fooArray[2].allFoo, "all Foo", "should just be a Foo?")
        }
        
        // The new object JSON
        let newJson = newObject.toJsonString()
        print("New JSON = \(newJson)")
        
        // The original and new JSON Should be the same
        XCTAssertEqual(json, newJson, "The json should be the same after serialization and deserialization")
    }
    
}



class Quz: EVObject {
    var fooArray: Array<Foo> = []
    var fooBar: Foo?
    var fooBaz: Foo?
    var fooFoo: Foo?
}

class Foo: EVObject {
    var allFoo: String = "all Foo"
    
    // What you need to do to get the correct type for when you deserialize inherited classes
    override func getSpecificType(_ dict: NSDictionary) -> EVReflectable {
        if dict["justBar"] != nil {
            return Bar()
        } else if dict["justBaz"] != nil {
            return Baz()
        }
        return self
    }
}

class Bar: Foo {
    var justBar: String = "For bar only"
}

class Baz: Foo {
    var justBaz: String = "For baz only"
}
