//
//  EVRelfectionEnheritanceTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/28/15.
//  Copyright © 2015 evict. All rights reserved.
//


import XCTest


/**
 Testing The serialize and deserialize when using object enheritance.
 */
class EVRelfectionEnheritanceTests: XCTestCase {
    
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
    
    func testEnheritanceDeserialize() {
        let quz = Quz()
        quz.fooBar = Bar()
        quz.fooBaz = Baz()
        quz.fooArray = [Bar(), Baz()]
        print(quz.toJsonString())
    }
    
    func testEnheritanceSerialize() {
        let quz = Quz()
        quz.fooBar = Bar()
        quz.fooBaz = Baz()
        quz.fooArray = [Bar(), Baz()]
        let json = quz.toJsonString()
        
        let newObject = Quux(json: json)
        print(newObject.toJsonString())
    }
}

class Quz: EVObject {
    var fooArray: Array<Foo> = []
    var fooBar: Foo?
    var fooBaz: Foo?
}

class Foo: EVObject {
    var allFoo: String = "all Foo"
    
}

class Bar : Foo {
    var justBar: String = "For bar only"
}

class Baz: Foo {
    var justBaz: String = "For baz only"
}

// What you need for a Deserialize when using object enheritance
class Quux: EVObject {
    var xfooArray: Array<Foo> = []
    var xfooBar: Foo?
    var xfooBaz: Foo?
    
    // This construction can be used to solve the multiple enheritance issue
    override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "fooBar":
            xfooBar = getFromDict(value as! NSDictionary)
        case "fooBaz":
            xfooBaz = getFromDict(value as! NSDictionary)
        case "fooArray":
            for item in value as! NSArray {
                xfooArray.append(getFromDict(item as! NSDictionary))
            }
        default:
            NSLog("WARNING: setValue for key '\(key)' should be handled.")
        }
    }
    
    // Get the right type based on what's in the dictionary
    private func getFromDict(dict: NSDictionary) -> Foo {
        if dict["justBar"] != nil {
            return Bar(dictionary: dict)
        }
        return Baz(dictionary: dict)
    }
}
