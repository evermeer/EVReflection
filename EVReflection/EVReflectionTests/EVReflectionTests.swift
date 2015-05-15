//
//  EVReflectionTests.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import XCTest

class EVReflectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassToAndFromString() {
        // Test the EVReflection class - to and from string
        var theObject = TestObject()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")
        
        if var nsobject = EVReflection.swiftClassFromString(theObjectString) {
            NSLog("object = \(nsobject)")
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

    func testClassToAndFromDictionary() {
        var theObject = TestObject2()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        var toDict = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if var nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject2 {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
            XCTAssert(theObject == nsobject, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }
    
    func testEquatable() {
        var theObjectA = TestObject2()
        theObjectA.objectValue = "value1"
        var theObjectB = TestObject2()
        theObjectB.objectValue = "value1"
        XCTAssert(theObjectA == theObjectB, "Pass")

        theObjectB.objectValue = "value2"
        XCTAssert(theObjectA != theObjectB, "Pass")
    }
    
    func testHashable() {
        var theObject = TestObject2()
        theObject.objectValue = "value1"
        var hash1 = theObject.hash
        NSLog("hash = \(hash)")
    }
    
    func testPrintable() {
        var theObject = TestObject2()
        theObject.objectValue = "value1"
        NSLog("theObject = \(theObject)")
    }

    func testNSCoding() {
        var theObject = TestObject2()
        theObject.objectValue = "value1"

        let fileDirectory =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString) ?? ""
        var filePath = fileDirectory.stringByAppendingPathComponent("temp.dat")
        
        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)
        
        // Read object from file
        var result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! TestObject2
        
        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }
    
    func testClassToAndFromDictionaryWithNullableType() {
        var theObject = TestObject3()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        var toDict = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if var nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject3 {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
            XCTAssert(theObject == nsobject, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }
    
    func testNSCodingWithNullableType() {
        var theObject = TestObject3()
        theObject.objectValue = "value1"
        theObject.nullableType = 3
        
        let fileDirectory =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString) ?? ""
        var filePath = fileDirectory.stringByAppendingPathComponent("temp.dat")
        
        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)
        
        // Read object from file
        var result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! TestObject3
        NSLog("unarchived result object = \(result)")

        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }


    func testClassToAndFromDictionaryConvenienceMethods() {
        var theObject = TestObject2()
        theObject.objectValue = "testing"
        var toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        var result = TestObject2(dictionary: toDict)
        XCTAssert(theObject == result, "Pass")
    }

    // You can initiate a diffrent type. Only the properties with matching dictionary keys will be set
    func testClassToAndFromDictionaryDiffrentType() {
        var theObject = TestObject3()
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        var toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        var result = TestObject2(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }

}
