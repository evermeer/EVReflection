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
    Get the string name for a class and then generate a class based on that string
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
    class SubObject2: EVObject {
        var field: String = "x"
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
        let json = x.toJsonString(.Default)
        XCTAssertTrue(!json.containsString("_default"), "Key should have been cleaned up")
        
        let y = EVReflection.fromDictionary(["a":"b"], anyobjectTypeString: "NotExistingClassName")
        XCTAssertNil(y, "Class is unknow, so we should not have an instance")
    }

    func testNSObjectArrayFromJson() {
        let x: [TestObject2c] = TestObject2c.arrayFromJson("[{\"objectValue\":\"tst\"},{\"objectValue\":\"tst2\"}]")
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
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary from 
     the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentType() {
        let theObject = TestObject3()
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        NSLog("\n\n===>You will now get a warning because TestObject2 does not have the property nullableType")
        let result = TestObject2(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }

    
    /**
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary 
     from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentTypeAlt() {
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        NSLog("\n\n===>You will now get 20+ warnings because TestObject3 can not handle most of TestObject4's properties")
        let result = TestObject3(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }
  

    /**
     Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary 
     from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
     */
    func testClassToJsonWithDateFormatter() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        EVReflection.setDateFormatter(dateFormatter)
        
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        theObject.myDate = NSDate()
        let json = theObject.toJsonString()
        NSLog("toJson = \(json)")
        XCTAssert(!(json.containsString(".") || json.containsString("/") || json.containsString("-")), "Pass") // The objects are not the same
        
        let newObject = TestObject4(json: json)
        XCTAssertEqual(theObject, newObject, "Should still be the same")
        theObject.myDate = NSDate().dateByAddingTimeInterval(3600)
        XCTAssert(theObject != newObject, "Should not be the same")
        
        EVReflection.setDateFormatter(nil)

    }
    
    func testArrayPropertyCompare() {
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        let dict = theObject.toDictionary()
        NSLog("toDict = \(dict)")
        let newObject = TestObject4(dictionary: dict)
        
        theObject.array.append(TestObject2())
        XCTAssert(theObject != newObject, "Should not be the same")
        newObject.array.append(TestObject2())
        XCTAssert(theObject == newObject, "Should be the same again")
        (theObject.array[0]).objectValue = "X"
        XCTAssert(theObject != newObject, "Should not be the same")
        (newObject.array[0]).objectValue = "X"
        XCTAssert(theObject == newObject, "Should be the same again")
        
        theObject.array3[0] = "Y"
        XCTAssert(theObject != newObject, "Should not be the same")
        newObject.array3[0] = "Y"
        XCTAssert(theObject == newObject, "Should be the same again")
    }
    
    func testXMLDictStructure() {
        // When using XMLDict, an array will be nested in a singel xml node which you probably want to skip in your object structure
        let xmlDict =  ["myString": "STR", "array": ["object2":[["objectValue":"STR2"], ["objectValue":"STR3"]]]]
        let obj = TestObject4(dictionary: xmlDict)
        XCTAssertEqual(obj.myString, "STR", "object myString value should have been STR")
        XCTAssertEqual(obj.array.count, 2, "There should be 1 vallue in the array")
        if obj.array.count == 2 {
            XCTAssertEqual(obj.array[0].objectValue, "STR2", "The first array object myString value should have been STR2")            
        }
    }
    
    func testCustomNestedArrays() {
        let json = "{\"containers\": [{ \"rows\": [{\"kind\": \"main\"}, {\"kind\": \"main2\"}] }, {\"rows\": [{\"kind\": \"main3\"}, {\"kind\": \"main4\"}, {\"kind\": \"main5\"}] }] }"
        
        //let json = "{\"containers\": [{ \"rows\": [{\"kind\": \"main\"}, {\"kind\": \"main2\"}] }, { \"rows\": [{\"kind\": \"main3\"}, {\"kind\": \"main4\"}] }] }"
        let c = TestObject8(json: json)
        XCTAssertEqual(c.containers.count, 2, "There should be 1 container")
        if c.containers.count == 2 {
            XCTAssertEqual(c.containers[0].rows.count, 2, "Container 0 should have 2 rows")
            if c.containers[0].rows.count == 2 {
                XCTAssertEqual(c.containers[0].rows[0].kind, "main", "Row 0 of container 0 should contain main" )
                XCTAssertEqual(c.containers[0].rows[1].kind, "main2", "Row 1 of container 0 should contain main2" )
            }
            XCTAssertEqual(c.containers[1].rows.count, 3, "Container 1 should have 3 rows")
            if c.containers[1].rows.count == 3 {
                XCTAssertEqual(c.containers[1].rows[0].kind, "main3", "Row 0 of container 1 should contain main3" )
                XCTAssertEqual(c.containers[1].rows[1].kind, "main4", "Row 1 of container 1 should contain main4" )
                XCTAssertEqual(c.containers[1].rows[2].kind, "main5", "Row 2 of container 1 should contain main5" )
            }
        }
    }

    
    /**
     Test if we can work with an object that contains all types of arrays
     */
    func testArrays() {
        let x = ArrayObjects()
        print(x.toJsonString())
    }
    
    func testCircular() {
        let circle: Circular1 = Circular1()
        circle.startCircle = Circular2()
        circle.startCircle!.createCircle = circle
        let json = circle.toJsonString()
        print("json = \(json)")
    }
    
    func testDictionary() {
        let json = DicTest().toJsonString()
        print("json = \(json)")
    }
    
    func testNilPropertyGetter() {
        
        let theObject = TestObjectWithNilConverters()
        theObject.optionalValue = "123"

        let json = theObject.toDictionary()
        
        let optionalValue = json["optionalValue"]
        XCTAssertNil(optionalValue)
    }
    
    func testNilPropertySetter() {
        
        let json = "{\"optionalValue\": \"123\"}"
        
        let theObject = TestObjectWithNilConverters(json: json)
        
        XCTAssertNil(theObject.optionalValue)
    }

    func testTypeForKey() {
        let theObject = TestObject4()
        let type = theObject.typeForKey("myInt")
        print("type of myInt = \(type)")
        XCTAssertEqual("\(type)", "Optional(Swift.Int)")
    }

    func testJSONArray() {
        let a = AA()
        let b = BB()
        b.val = 1
        a.bs.append(b)
        a.bs.append(b)
        a.bs.append(b)
        a.bs.append(b)
        a.bs.append(b)
        a.bs.append(b)
        a.bs.append(b)
        let str = a.toJsonString()
        print(str)
        let a2 = AA(json: str)
        print(a2.toJsonString())
    }
    
    func testNestedArry() {
        let json = "{\"date\": 2457389.3333330001,\"results\": { \"sun\": [[559285.95145709824, 202871.33591198301, 61656.198554897906], [127.6163120820332, 948.44727756795123, 406.68471093096883]], \"geomoon\": [[-401458.60657087743, -43744.769596474769, -11058.709613333322], [8433.3114508170656, -78837.790870237863, -26279.67592282737]] }, \"unit\": \"km\" }"
        let myObject = NestedArrays(json: json)
        print(myObject.toJsonString())
    }
    
}
