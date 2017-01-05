//
//  EVReflectionEVObjectTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/26/15.
//  Copyright © 2015 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionEVObjectTests: XCTestCase {
    
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
        
        let theObjectA2 = TestObject2b()
        theObjectA2.objectValue = "value1"
        
        XCTAssert(!theObjectA.isEqual(theObjectA2), "Pass")
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
        EVReflection.logObject(theObject)
    }
    
    /**
     Archive an object with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal
     */
    func testNSCoding() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp.dat")
        
        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)
        
        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? TestObject2
        
        // Test if the objects are the same
        XCTAssert(theObject.isEqual(result), "Pass")
        XCTAssert(theObject == result, "Pass")
    }
    
    func testNSCodingConvenience() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        
        let didSaveTemp = theObject.saveToTemp("temp.dat")
        XCTAssertTrue(didSaveTemp, "Could not save to temp2.dat")

        let result = TestObject2(fileNameInTemp: "temp.dat")
        
        XCTAssert(theObject == result, "Pass")
        
        #if os(tvOS)
            // Save to documents folder is not supported on tvOS
        #else
            let didSaveDoc = theObject.saveToDocuments("temp2.dat")
            XCTAssertTrue(didSaveDoc, "Could not save to temp2.dat")
            
            let result2 = TestObject2(fileNameInDocuments: "temp2.dat")
            
            XCTAssert(theObject == result2, "Pass")
        #endif
    }
    
    func testNSCodingSubObject() {
        let theObject = TestObject7()
        let subObject = SubObject()
        theObject.subOne = subObject
        theObject.subTwo = subObject
        theObject.subOne!.field = "test"
        XCTAssertEqual(theObject.subOne!.field, theObject.subTwo!.field, "Is the same object and should be the same")
        
        let didSaveTemp = theObject.saveToTemp("temp.dat")
        XCTAssertTrue(didSaveTemp, "Could not save to temp2.dat")
        
        let result = TestObject7(fileNameInTemp: "temp.dat")
        XCTAssert(theObject == result, "The restored object is the same as the original")
        
        XCTAssertEqual(theObject.subOne!.field, theObject.subTwo!.field, "Is the same object and should be the same")
        theObject.subOne!.field = "2nd test"
        XCTAssertEqual(theObject.subOne!.field, theObject.subTwo!.field, "Is the same object and should be the same")
    }
    
    /**
     Archive an object that contains a nullable type with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal. We are using the workaround in TestObject3 to solve the setvalue for key issue in Swift 1.2
     
     */
    func testNSCodingWithNullableType() {
        let theObject = TestObject3()
        theObject.objectValue = "value1"
        theObject.nullableType = 3
        
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp.dat")
        
        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)
        
        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? TestObject3
        NSLog("unarchived result object = \(result)")
        
        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }
    
    /**
    */
    func testNSCodingSubObjectArray() {
        let rootObject = TestRootObject()
        rootObject.id = "root"
        let inner1 = TestInnerObject()
        inner1.id = "inner1"
        let inner2 = TestInnerObject()
        inner1.id = "inner2"
        rootObject.array = [inner1, inner2]
        
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("rootObject.dat")
        
        // Write object to file
        NSKeyedArchiver.archiveRootObject(rootObject, toFile: filePath)
        
        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? TestRootObject
        
        XCTAssert(result!.array!.count == 2, "Array size should be 2")
        
        //Crash here
        let out1 = result!.array?.first
    
        XCTAssert(out1!.id == "inner1")
    }

    func testNSCodingSubObjectArray() {
        let rootObject = TestRootObject()
        rootObject.id = "root"
        let inner1 = TestInnerObject()
        inner1.id = "inner1"
        let inner2 = TestInnerObject()
        inner2.id = "inner2"
        rootObject.array = [inner1, inner2]

        rootObject.saveToTemp("rootObject.dat")
        let result = TestRootObject(fileNameInTemp: "rootObject.dat")

        XCTAssert(result.array?.count == 2, "Array size should be 2")

        //Crash here
       let out1 = result.array?.first

        XCTAssert(out1?.id == "inner1")
    }
    
}


open class TestBaseObject: EVObject {
    var id: String?
}

open class TestRootObject: TestBaseObject {
    var array: [TestInnerObject]?
}

open class TestInnerObject: TestBaseObject {
}
