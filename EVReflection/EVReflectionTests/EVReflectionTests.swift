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

        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp.dat")

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

        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp.dat")

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
    
    /**
    Test the conversion from string to number and from number to string
    */
    func testTypeDict() {
        let i:Int32 = 1
        let s:String = "2"
        let dictOriginal: NSMutableDictionary = NSMutableDictionary()
        dictOriginal.setValue(s, forKey: "myInt")
        dictOriginal.setValue(NSNumber(int:i), forKey: "myString")
        let a = TestObject4(dictionary: dictOriginal)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
    }
    
    func testTypeDictAllString() {
        let dict = ["myString":"1", "myInt":"2", "myFloat":"2.1", "myBool":"1"]
        let a = TestObject4(dictionary: dict)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
    }
    
    func testTypeDict2AllNumeric() {
        let dict = ["myString":1, "myInt":2, "myFloat":2.1, "myBool":1]
        let a = TestObject4(dictionary: dict)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
    }
    
    /**
    Test various large number conversions to NSNumber
    */
    func testNSNumber() {
        let test1 = NSNumber(double: Double(Int.max))
        let (value1, _) = EVReflection.valueForAny("", key: "", anyValue: test1)
        XCTAssert(value1 as? NSNumber == NSNumber(long: Int.max), "Values should be same for type NSNumber")
        
        let test2:Float = 458347978508
        let (value2, _) = EVReflection.valueForAny("", key: "", anyValue: test2)
        XCTAssert(value2 as? NSNumber == NSNumber(float: 458347978508), "Values should be same for type Float")

        let test3:Double = 458347978508
        let (value3, _) = EVReflection.valueForAny("", key: "", anyValue: test3)
        XCTAssert(value3 as? NSNumber == NSNumber(double: 458347978508), "Values should be same for type Double")

        let test4:Int64 = Int64.max
        let (value4, _) = EVReflection.valueForAny("", key: "", anyValue: test4)
        XCTAssert(value4 as? NSNumber == NSNumber(longLong: Int64.max), "Values should be same for type Int64")

        let test5:Int32 = Int32.max
        let (value5, _) = EVReflection.valueForAny("", key: "", anyValue: test5)
        XCTAssert(value5 as? NSNumber == NSNumber(int: Int32.max), "Values should be same for type Int32")

        let test6:Int = Int.max
        let (value6, _) = EVReflection.valueForAny("", key: "", anyValue: test6)
        XCTAssert(value6 as? NSNumber == NSNumber(integer: Int.max), "Values should be same for type Int64")
    }
    
    func testCustomPropertyMapping() {
        let dict = ["Name":"just a field", "dummyKeyInJson":"will be ignored", "keyInJson":"value for propertyInObject", "ignoredProperty":"will not be read or written"]
        let a = TestObject5(dictionary: dict)
        XCTAssertEqual(a.Name, "just a field", "Name should containt 'just a field'")
        XCTAssertEqual(a.propertyInObject, "value for propertyInObject", "propertyInObject should containt 'value for propertyInObject'")
        XCTAssertEqual(a.ignoredProperty, "", "ignoredProperty should containt ''")
        
        let toDict = a.toDictionary()
        let dict2 = ["Name":"just a field","keyInJson":"value for propertyInObject"]
        XCTAssertEqual(toDict, dict2, "export dictionary should only contain a Name and keyInJson")
    }
    
    func testCamelCaseToUndersocerMapping() {
        XCTAssertEqual(EVReflection.CamelCaseToUnderscores("swiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        XCTAssertEqual(EVReflection.CamelCaseToUnderscores("SwiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        
    }
    
}
