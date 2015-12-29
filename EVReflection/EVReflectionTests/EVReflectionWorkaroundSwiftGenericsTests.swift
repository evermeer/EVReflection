//
//  EVReflectionWorkaroundSwiftGenericsTests.swift
//
//  Created by Edwin Vermeer on 8/10/15.
//  Copyright (c) 2015. All rights reserved.
//

import XCTest
@testable import EVReflection


/**
Testing the workaround for generics.
*/
class EVReflectionWorkaroundSwiftGenericsTests: XCTestCase {
    
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

    func testSetValueGenericClass() {
        let a = MyGenericObject<NSString>()
        a.setValue("data", forUndefinedKey: "data")
        a.setValue("gone", forUndefinedKey: "wrongKey")
        XCTAssertEqual(a.data as String, "data", "data should contain data")
    }

    func testSetValueIncorrectGenericClass() {
        let a = MyIncorrectGenericObject<NSString>()
        a.setValue("data", forUndefinedKey: "data")
        a.setValue("gone", forUndefinedKey: "wrongKey")
        XCTAssertEqual(a.data, "", "data should still be an empty string")
    }
    
    
    func testGenericsJson() {
        let json:String = "{\"test\":\"test\", \"data\":\"data\", \"array\":[\"val1\",\"val2\",\"val3\"]}"
        let a = MyGenericObject<NSString>(json: json)
        XCTAssertEqual(a.test, "test", "test should contain test")
        XCTAssertEqual(a.data as String, "data", "data should contain data")
        XCTAssertEqual(a.array.count, 3, "data should contain data")
    }

    func testGenericsJson2() {
        EVReflection.setBundleIdentifier(InstanceObject)
        let json:String = "{\"test\":\"test\", \"data\":{\"name\":\"data\"}, \"array\":[{\"name\":\"val1\"}, {\"name\":\"val2\"}, {\"name\":\"val3\"}]}"
        let a = MyGenericObject<InstanceObject>(json: json)
        XCTAssertEqual(a.test, "test", "test should contain test")
        XCTAssertEqual(a.data.name, "data", "data.name should contain data")
        XCTAssertEqual(a.array.count, 3, "array should contain 3 elements")
        if a.array.count == 3 {
            XCTAssertEqual(a.array[0].name!, "val1", "array[0].name should contain val1")
            XCTAssertEqual(a.array[1].name!, "val2", "array[1].name should contain val2")
            XCTAssertEqual(a.array[2].name!, "val3", "array[2].name should contain val2")
        }
    }
    
    func testClassToAndFromString() {
        // Test the EVReflection class - to and from string
        let theObject = MyGenericObject<InstanceObject>()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")
        
        let nsobject = EVReflection.swiftClassFromString(theObjectString)
        NSLog("object = \(nsobject)")
        XCTAssert(nsobject != nil, "Pass")
    }
    
    func testGenericSubObject() {
        let foo = TestGenerics()
        foo.bar.data.name = "Test"
        
        let json = foo.toJsonString()
        let foo2 = TestGenerics(json: json)
        XCTAssertEqual(foo, foo2, "Objects should be the same")
    }
}


// Only put the generic properties in this class. put the rest in a base class
// Add the protocol EVGenericsKVC so that we still can have a setValue forUndefinedKey like we adr used to
public class MyGenericObject<T where T:NSObject>: MyGenericBase, EVGenericsKVC {
    var data: T = T()
    var array: [T] = [T]()
    
    required public init() {
        super.init()
    }
    
    public override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "data":
            data = value as! T
        case "array":
            array = value as! [T]
        default:
            print("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
}


public class MyIncorrectGenericObject<T where T:NSObject>: MyGenericBase, EVGenericsKVC {
    var data: T = T()
    var array: [T] = [T]()
    
    required public init() {
        super.init()
    }
}


// Put the rest of the properties in a base class like this. Otherwise you have to handle each in the setValue forUndefinedKey
public class MyGenericBase: EVObject {
    var test : String = ""
}

public class InstanceObject: EVObject {
    var name:String?
}

public class TestGenerics: EVObject  {
    var bar : MyGenericObject<InstanceObject> = MyGenericObject<InstanceObject>()
    
    public override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "bar":
            bar = value as! MyGenericObject<InstanceObject>
        default:
            print("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
}
