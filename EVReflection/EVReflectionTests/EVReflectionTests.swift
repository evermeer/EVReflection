//
//  EVReflectionTests.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import XCTest
@testable import EVReflection

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

        let nsobject = EVReflection.swiftClassFromString(theObjectString)
        NSLog("object = \(nsobject)")
        XCTAssert(nsobject != nil, "Pass")

        let theObject2 = SubObject2()
        let theObject2String: String = EVReflection.swiftStringFromClass(theObject2)
        NSLog("swiftStringFromClass = \(theObject2String)")
        
        let nsobject2 = EVReflection.swiftClassFromString(theObject2String)
        NSLog("object = \(nsobject2)")
        XCTAssert(nsobject != nil, "Pass")
        
        
        let nsobject3 = EVReflection.swiftClassFromString("NSObject")
        XCTAssertNotNil(nsobject3, "Pass")

        let nsobject4 = EVReflection.swiftClassFromString("NotExistingClassName")
        XCTAssertNil(nsobject4, "Pass")
        
    }
    class SubObject2:EVObject {
        var field:String = "x"
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
        let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject2
        NSLog("object = \(nsobject), objectValue = \(nsobject?.objectValue)")
        XCTAssert(theObject == nsobject, "Pass")
    }

    func testNSObjectFromDictionary() {
        let x = TestObject2c(dictionary: ["objectValue": "tst", "default":"default"])
        XCTAssertEqual(x.objectValue, "tst", "objectValue should have been set")
        XCTAssertEqual(x._default, "default", "default should have been set")
        let json = x.toJsonString(true)
        XCTAssertTrue(!json.containsString("_default"), "Key should have been cleaned up")
        
        let y = EVReflection.fromDictionary(["a":"b"], anyobjectTypeString: "NotExistingClassName")
        XCTAssertNil(y, "Class is unknow, so we should not have an instance")
    }

    func testNSObjectArrayFromJson() {
        let x:[TestObject2c] = TestObject2c.arrayFromJson("[{\"objectValue\":\"tst\"},{\"objectValue\":\"tst2\"}]")
        XCTAssertEqual(x.count, 2, "There should have been 2 elements")
        if x.count == 2 {
            XCTAssertEqual(x[0].objectValue, "tst", "objectValue should have been set")
            XCTAssertEqual(x[1].objectValue, "tst2", "objectValue should have been set")            
        }
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
        let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject3
        NSLog("object = \(nsobject), objectValue = \(nsobject?.objectValue)")
        XCTAssert(theObject == nsobject, "Pass")
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
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentTypeAlt() {
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject3(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }
  
    
    /**
     Test if we can work with an object that contains all types of arrays
     */
    func testArrays() {
        let x = ArrayObjects()
        print(x.toJsonString())
    }
}










