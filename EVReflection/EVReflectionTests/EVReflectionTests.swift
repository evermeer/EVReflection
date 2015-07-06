//
//  EVReflectionTests.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import XCTest


/**
Testing EVReflection
*/
class EVReflectionTests: XCTestCase {

    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Get the string name for a clase and then generate a class based on that string
    */
    func testClassToAndFromString() {
        // Test the EVReflection class - to and from string
        let theObject = TestObject()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")

        if let nsobject = EVReflection.swiftClassFromString(theObjectString) {
            NSLog("object = \(nsobject)")
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

    /**
    Create a dictionary from an object where each property has a key and then create an object and set all objects based on that directory.
    */
    func testClassToAndFromDictionary() {
        let theObject = TestObject2()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        let (toDict, _) = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject2 {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
            XCTAssert(theObject == nsobject, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

    /**
    Create 2 objects with the same property values. Then they should be equal. If you change a property then the objects are not equeal anymore.
    */
    func testEquatable() {
        let theObjectA = TestObject2()
        theObjectA.objectValue = "value1"
        let theObjectB = TestObject2()
        theObjectB.objectValue = "value1"
        XCTAssert(theObjectA == theObjectB, "Pass")

        theObjectB.objectValue = "value2"
        XCTAssert(theObjectA != theObjectB, "Pass")
    }

    /**
    Just get a hash from an object
    */
    func testHashable() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        let hash = theObject.hash
        NSLog("hash = \(hash)")
    }

    /**
    Print an object with all its properties.
    */
    func testPrintable() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        NSLog("theObject = \(theObject)")
    }

    /**
    Archive an object with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal
    */
    func testNSCoding() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"

        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("temp.dat")

        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)

        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? TestObject2

        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }

    /**
    Create a dictionary from an object that contains a nullable type. Then read it back. We are using the workaround in TestObject3 to solve the setvalue for key issue in Swift 1.2
    */
    func testClassToAndFromDictionaryWithNullableType() {
        let theObject = TestObject3()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        let (toDict, _) = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject3 {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
            XCTAssert(theObject == nsobject, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

    /**
    Archive an object that contains a nullable type with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal. We are using the workaround in TestObject3 to solve the setvalue for key issue in Swift 1.2

    */
    func testNSCodingWithNullableType() {
        let theObject = TestObject3()
        theObject.objectValue = "value1"
        theObject.nullableType = 3

        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("temp.dat")

        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)

        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? TestObject3
        NSLog("unarchived result object = \(result)")

        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }

    /**
    Test the convenience methods for getting a dictionary and creating an object based on a dictionary.
    */
    func testClassToAndFromDictionaryConvenienceMethods() {
        let theObject = TestObject2()
        theObject.objectValue = "testing"
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject2(dictionary: toDict)
        XCTAssert(theObject == result, "Pass")
    }

    /**
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentType() {
        let theObject = TestObject3()
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject2(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }
}
