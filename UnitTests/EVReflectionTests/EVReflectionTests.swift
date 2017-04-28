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
    Get the string name for a class and then generate a class based on that string
    */
    func testClassToAndFromString() {
        // Test the EVReflection class - to and from string
        let theObject = TestObject()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")

        let nsobject = EVReflection.swiftClassFromString(theObjectString)
        NSLog("object = \(nsobject.debugDescription )")
        XCTAssert(nsobject != nil, "Pass")

        let theObject2 = SubObject2()
        let theObject2String: String = EVReflection.swiftStringFromClass(theObject2)
        NSLog("swiftStringFromClass = \(theObject2String)")
        
        let nsobject2 = EVReflection.swiftClassFromString(theObject2String)
        NSLog("object = \(nsobject2.debugDescription )")
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
        NSLog("object = \(nsobject.debugDescription), objectValue = \(nsobject?.objectValue ?? "")")
        XCTAssert(theObject == nsobject, "Pass")
    }

    func testNSObjectFromDictionary() {
        let x = TestObject2c(dictionary: ["objectValue": "tst", "default":"default"])
        XCTAssertEqual(x.objectValue, "tst", "objectValue should have been set")
        XCTAssertEqual(x._default, "default", "default should have been set")
        let json = x.toJsonString([.DefaultSerialize, .KeyCleanup])
        XCTAssertTrue(!json.contains("_default"), "Key should have been cleaned up")
        
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
        NSLog("object = \(nsobject.debugDescription), objectValue = \(nsobject?.objectValue ?? "")")
        XCTAssert(theObject == nsobject, "Pass")
    }

    /**
    Test the convenience methods for getting a dictionary and creating an object based on a dictionary.
    */
    func testClassToAndFromDictionaryConvenienceMethods() {
        let theObject: TestObject2 = TestObject2()
        theObject.objectValue = "testing"
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result: TestObject2 = TestObject2(dictionary: toDict)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        EVReflection.setDateFormatter(dateFormatter)
        
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        theObject.myDate = Date()
        let json = theObject.toJsonString()
        NSLog("toJson = \(json)")
        XCTAssert(!(json.contains(".") || json.contains("/") || json.contains("-")), "Pass") // The objects are not the same
        
        let newObject = TestObject4(json: json)
        XCTAssertEqual(theObject, newObject, "Should still be the same")
        theObject.myDate = Date().addingTimeInterval(3600)
        XCTAssert(theObject != newObject, "Should not be the same")
        
        EVReflection.setDateFormatter(nil)

    }
    
    func testArrayPropertyCompare() {
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        theObject.array[0].objectValue = "x1"
        theObject.array[1].objectValue = "x2"
        let dict = theObject.toDictionary()
        NSLog("toDict = \(dict)")
        let newObject = TestObject4(dictionary: dict)

        XCTAssert(theObject == newObject, "Should be the same")

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
        // When using XMLDict, an array will be nested in a singel xml node which you probably want to skip in your object structure.
        // The only requirement is that the name of the key should be the same as the as the object type (in lowercase).
        let xmlDict =  ["myString": "STR", "array": ["testobject2":[["objectValue":"STR2"], ["objectValue":"STR3"]]]] as [String : Any]
        let obj = TestObject4(dictionary: xmlDict as NSDictionary)
        XCTAssertEqual(obj.myString, "STR", "object myString value should have been STR")
        XCTAssertEqual(obj.array.count, 2, "There should be 2 vallues in the array")
        if obj.array.count == 2 {
            XCTAssertEqual(obj.array[0].objectValue, "STR2", "The first array object myString value should have been STR2")            
            XCTAssertEqual(obj.array[1].objectValue, "STR3", "The second array object myString value should have been STR3")
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
        print(x)
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

        let dict = theObject.toDictionary()
        print("dict = \(dict)")
        
        let optionalValue = dict["optionalValue"]
        XCTAssert(optionalValue as? NSNull != nil, "Should have been NSNull")
    }
    
    func testNilPropertySetter() {
        
        let json = "{\"optionalValue\": \"123\"}"
        
        let theObject = TestObjectWithNilConverters(json: json)
        
        XCTAssertNil(theObject.optionalValue)
    }

    func testTypeForKey() {
        let theObject = TestObject4()
        let type = theObject.typeForKey("myInt")
        print("type of myInt = \(type.debugDescription)")
        XCTAssertEqual("\(type.debugDescription)", "Optional(Swift.Int)")
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

    func testValidationStorage() {
        let test1 = EVObject()
        let test2 = EVObject()
        let test3 = EVObject()

        test1.addStatusMessage(DeserializationStatus.Custom, message: "Custom1")
        test1.addStatusMessage(DeserializationStatus.MissingKey, message: "Custom2")
        test2.addStatusMessage(DeserializationStatus.Custom, message: "Custom3")
        test3.addStatusMessage(DeserializationStatus.IncorrectKey, message: "Custom4")
        
        XCTAssertEqual(test1.evReflectionStatuses.count, 2, "We should have 2 validation result")
        XCTAssertEqual(test2.evReflectionStatuses.count, 1, "We should have 1 validation result")
        XCTAssertEqual(test3.evReflectionStatuses.count, 1, "We should have 1 validation result")

        XCTAssertEqual(test1.evReflectionStatus(), [.Custom, .MissingKey], "We should have a .Custom and .MissingKey status")
        XCTAssertEqual(test2.evReflectionStatus(), .Custom, "We should have a .Custom status")
        XCTAssertEqual(test3.evReflectionStatus(), .IncorrectKey, "We should have a .IncorrectKey status")
    }
    
    func testValidation() {
        // Test missing required key
        let json = "{\"requiredKey1\": \"Value1\", \"requiredKey2\":\"Value2\"}"
        let test = ValidateObject(json: json)
        XCTAssertNotEqual(test.evReflectionStatus(), .none, "We should have a not .None status")
        XCTAssertEqual(test.evReflectionStatuses.count, 1, "We should have 1 validation result")
        for (status, message) in test.evReflectionStatuses {
            print("Validation result: Status = \(status), Message = \(message)")
        }

        // Test aditional key
        let json2 = "{\"requiredKey1\": \"Value1\", \"requiredKey2\":\"Value2\", \"requiredKey3\":\"Value3\", \"randomKey\":\"Value4\"}"
        let test2 = ValidateObject(json: json2)
        XCTAssertNotEqual(test.evReflectionStatus(), .none, "We should have a not .None status")
        XCTAssertEqual(test2.evReflectionStatuses.count, 1, "We should have 1 validation result")
        for (status, message) in test2.evReflectionStatuses {
            print("Validation result: Status = \(status), Message = \(message)")
        }
    }
    
    func testIssue81() {
        let a = A81()
        a.openId = "value"
        let json = a.toJsonString()
        print(json)
        XCTAssertEqual(json, "{\"openId\":\"value\"}", "Incorrect serialization to json")
    }
    
    func testLazy() {
        let a = ImLazy()
        var json = a.toJsonString()
        print(json)
        a.lazyInt = 66
        a.LazyString = "D"
        json = a.toJsonString()
        print(json)
        let b = ImLazy(json: json)
        print(b)
    }
    
    func testArrayFromNotArray() {
        let normal = NSDictionary(dictionary: ["bs": [["val": 1], ["val": 2]]])
        print(String(describing: normal))
        let aaNormal: AA = AA(dictionary: normal)
        print(String(describing: aaNormal.toDictionary()))
        XCTAssertEqual(String(describing: normal), String(describing: aaNormal.toDictionary()))
        
        let abnormal = NSDictionary(dictionary: ["bs": ["val": 1]])
        print(String(describing: abnormal))
        let aaAbnormal: AA = AA(dictionary: abnormal)
        print(String(describing: aaAbnormal.toDictionary()))
        XCTAssert(aaAbnormal.bs.count > 0)
        if aaAbnormal.bs.count > 0 {
            XCTAssertEqual(aaAbnormal.bs[0].val, 1)
        }
        
        let arrayDic = NSDictionary(dictionary: [
            "strings": ["a", "b"],
            "nilObjects": [["field" : "value1"],["field": "value2"]],
            "nilObjectsForced": [["field" : "value3"],["field": "value4"]],
            "subobjects": [["field" : "value5"],["field": "value6"]]
            ])
        
        let arrObj: ArrayObjects = ArrayObjects(dictionary: arrayDic)
        print(arrObj)
        XCTAssertEqual((arrayDic["strings"] as! NSArray), NSArray(array: arrObj.strings))
        XCTAssert(arrObj.nilObjects?.count ?? 0 == 2, "Should have contained 2 objects")
        XCTAssert(arrObj.nilObjectsForced.count == 2, "Should have contained 2 objects")
        XCTAssert(arrObj.subobjects.count == 2, "Should have contained 2 objects")
        
        let arrayDic2 = NSDictionary(dictionary: ["strings": "a"])
        let arrObj2: ArrayObjects = ArrayObjects(dictionary: arrayDic2)
        print(arrObj2)
        XCTAssertEqual(arrObj2.strings[0], "a")
    }
    
    func testIssue33() {
        let json = "{\"id\":121,\"active\":false}"
        let object = MyObject(json: json)
        let newJson = object.toJsonString()
        print("back to json = \(newJson)\n\n\(object)")
    }
  
    func testImplicitlyUnwrappedOptionalProperty() {
        let nested = NSDictionary(dictionary: ["property1": 10, "property2": 20])
        print(String(describing: nested))
        let parentWithChild = NSDictionary(dictionary: ["iuoObject": nested, "control": "testVal"])
        print(String(describing: parentWithChild))
        
        let a: NestedIUOObject = NestedIUOObject(dictionary: nested)
        XCTAssertEqual(a.property1, 10)
        XCTAssertEqual(a.property2, 20)
        
        let b = NestedIUOObjectParent(dictionary: parentWithChild)
        XCTAssertNotNil(b.iuoObject)
        XCTAssertEqual(b.iuoObject.property1, 10)
        XCTAssertEqual(b.iuoObject.property2, 20)
        XCTAssertEqual(b.control, "testVal")
        
        let parentNoChild = NSDictionary(dictionary: ["control": "testVal"])
        print(String(describing: parentWithChild))
        let c = NestedIUOObjectParent(dictionary: parentNoChild)
        XCTAssertNil(c.iuoObject)
        XCTAssertEqual(c.control, "testVal")
        
        let parentWithChildren = NSDictionary(dictionary: ["iuoObjects": [nested, nested], "control": "testVal"])
        let d: NestedIUOObjectsArrayParent = NestedIUOObjectsArrayParent(dictionary: parentWithChildren)
        XCTAssertNotNil(d.iuoObjects)
        XCTAssertEqual(d.iuoObjects.count, 2)
        let child1 = d.iuoObjects[0]
        XCTAssertEqual(child1.property1, 10)
        XCTAssertEqual(child1.property2, 20)
        XCTAssertEqual(d.control, "testVal")
    }
    
    func testDictionaryToJson() {
        let dict1: NSDictionary = [
            "requestId": "request",
            "postcode": "1111AA",
            "houseNumber": "1"
        ]
        let json = dict1.toJsonString()
        print("dict:\n\(dict1)\n\njson:\n\(json)")
        let dict2 = NSMutableDictionary(json: json)
        print("dict2:\n\(dict2)")

        let dict3: NSDictionary = [
            "requestId": "post",
            "postcode": "1234AA",
            "houseNumber": "3"
        ]
        let array:[NSDictionary] = [dict1, dict2, dict3]
        let jsonArray = array.toJsonStringArray()
        
        print("json array: \n\(jsonArray)")
        let array2 = [NSDictionary](jsonArray: jsonArray)
        print("array2:\n\(array2)")
    }

    func testWrappedArray(){
        let json = "{\"array\":{ \"data\":[{\"openId\":\"value1\"},{\"openId\":\"value2\"}]}}"
        let obj = A81a(json: json)
        print(obj)
    }

    func testNestedArray(){
        let json = "{\"array\":[[{\"openId\":\"value1\"},{\"openId\":\"value2\"}],[{\"openId\":\"value3\"},{\"openId\":\"value4\"}]]}"
        let obj = A81b(json: json)
        print(obj)
    }

    func testNestedNestedArray(){
        let json = "{\"array\":[[[{\"openId\":\"value1\"},{\"openId\":\"value2\"}],[{\"openId\":\"value3\"},{\"openId\":\"value4\"}]]]}"
        let obj = A81c(json: json)
        print(obj)
    }
}


class MKPolygon: NSObject { }
extension MKPolygon: EVReflectable { }


class A81a: EVObject {
    var array: [A81] = []
}

//TODO: fix nested array bug
class A81b: EVObject {
    var array: [[A81]] = [[]]
    
    override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [(key: "-array",
                 decodeConverter: {
                    let x = $0
                    let v = (((x as! NSArray)[0] as! NSArray)[0] as! NSDictionary)["openId"]!
                    self.array = x as? [[A81]] ?? [[A81]]()
                 }, encodeConverter: { return self.array })]
    }
}

class A81c: EVObject {
    var array: [[[A81]]] = [[[]]]
}

class A81: EVObject {
    var openId: String = ""
}


class MyObject : EVObject {
    var id : Int = 0
    var active: Bool = false
}



