//
//  EVReflectionWorkaroundsTests.swift
//
//  Created by Edwin Vermeer on 7/23/15.
//  Copyright (c) 2015. All rights reserved.
//

import XCTest
@testable import EVReflection


/**
Testing The 3 propery types that need a workaround.
*/
class EVReflectionWorkaroundsTests: XCTestCase {
    
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
    
    func testWorkaroundsSmoketest() {
        let json: String = "{\"nullableType\": 1,\"enumType\": 0, \"list\": [ {\"nullableType\": 2}, {\"nullableType\": 3}] }"
        let status = WorkaroundObject(json: json)
        XCTAssertTrue(status.nullableType == 1, "the nullableType should be 1")
        XCTAssertTrue(status.enumType == .NotOK, "the status should be NotOK")
        XCTAssertTrue(status.list.count == 2, "the list should have 2 items")
        if status.list.count == 2 {
            XCTAssertTrue(status.list[0]?.nullableType == 2, "the first item in the list should have nullableType 2")
            XCTAssertTrue(status.list[1]?.nullableType == 3, "the second item in the list should have nullableType 3")
        }
    }

    func testWorkaroundsToJson() {
        let initialJson: String = "{\"nullableType\": 1,\"enumType\": 0, \"list\": [ {\"nullableType\": 2}, {\"nullableType\": 3}], \"unknownKey\": \"some\" }"
        let initialStatus = WorkaroundObject(json: initialJson)
        let json = initialStatus.toJsonString()
        let status = WorkaroundObject(json: json)
        print("To JSON = \(json)")
        XCTAssertTrue(status.nullableType == 1, "the nullableType should be 1")
        XCTAssertTrue(status.enumType == .NotOK, "the status should be NotOK")
        XCTAssertTrue(status.list.count == 2, "the list should have 2 items")
        if status.list.count == 2 {
            XCTAssertTrue(status.list[0]?.nullableType == 2, "the first item in the list should have nullableType 2")
            XCTAssertTrue(status.list[1]?.nullableType == 3, "the second item in the list should have nullableType 3")
        }
    }
    

    func testWorkaroundsCustomDictionary() {
        let json: String = "{\"dict\" : {\"firstkey\": {\"field\":5},  \"secondkey\": {\"field\":35}}}"
        let doc = WorkaroundObject(json: json)
        XCTAssertEqual(doc.dict.count, 2, "Should have 2 items in the dictionary")
        XCTAssertEqual(doc.dict["firstkey"]?.field, "5", "First sentence should have id 5")
        XCTAssertEqual(doc.dict["secondkey"]?.field, "35", "Second sentence should have id 35")
    }
    
    func testStruct() {
        let event = WorkaroundObject()
        event.structType = CGPoint(x: 2, y: 3)
        
        let json = event.toJsonString()
        print("json = \(json)")
        
        let newEvent = WorkaroundObject(json:json)
        XCTAssertEqual(newEvent.structType.x, 2, "The location x should have been 2")
        XCTAssertEqual(newEvent.structType.y, 3, "The location y should have been 3")
    }
}




//
class WorkaroundObject: EVObject, EVArrayConvertable, EVDictionaryConvertable {
    
    enum StatusType: Int, EVRawInt {
        case NotOK = 0
        case OK = 1
    }
    
    var nullableType: Int?
    var enumType: StatusType = .OK
    var list: [WorkaroundObject?] = [WorkaroundObject?]()
    var dict: [String: SubObject] = [:]
    var structType: CGPoint = CGPoint(x: 0, y: 0)
    
    // Handling the setting of non key-value coding compliant properties
    override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "nullableType":
            nullableType = value as? Int
        case "enumType":
            if let rawValue = value as? Int {
                if let status =  StatusType(rawValue: rawValue) {
                    self.enumType = status
                }
            }
        case "list":
            if let list = value as? NSArray {
                self.list = []
                for item in list {
                    self.list.append(item as? WorkaroundObject)
                }
            }
        case "dict":
            if let dict = value as? NSDictionary {
                self.dict = [:]
                for (key, value) in dict {
                    self.dict[key as? String ?? ""] = (value as? SubObject)
                }
            }
        case "structType":
            if let dict = value as? NSDictionary {
                if let x = dict["x"] as? NSNumber, let y = dict["y"] as? NSNumber {
                    structType = CGPoint(x: CGFloat(x), y: CGFloat(y))
                }
            }
        default:
            print("---> setValue for key '\(key)' should be handled.")
        }
    }
    
    // Implementation of the EVArrayConvertable protocol for handling an array of nullble objects.
    func convertArray(key: String, array: Any) -> NSArray {
        assert(key == "list", "convertArray for key \(key) should be handled.")

        let returnArray = NSMutableArray()
        for item in (array as? [WorkaroundObject?]) ?? [WorkaroundObject?]() {
            if item != nil {
                returnArray.addObject(item!)
            }
        }
        return returnArray
    }

    // Implementation of the EVDictionaryConvertable protocol for handling a Swift dictionary.
    func convertDictionary(field: String, dict: Any) -> NSDictionary {
        assert(field == "dict", "convertArray for key \(field) should be handled.")
    
        let returnDict = NSMutableDictionary()
        for (key, value) in dict as? NSDictionary ?? NSDictionary() {
            returnDict[key as? String ?? ""] = SubObject(dictionary: value as? NSDictionary ?? NSDictionary())
        }
        return returnDict
    }
}
