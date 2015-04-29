//
//  EVReflectionTests.swift
//  EVReflectionTests
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015 evict. All rights reserved.
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
        var theObject = TestObject()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        var toDict = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if var nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
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

        let fileDirectory =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString)
        var filePath = fileDirectory.stringByAppendingPathComponent("temp.dat")
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)
        
        var result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! TestObject2
        
        XCTAssert(theObject == result, "Pass")
        
    }
}
