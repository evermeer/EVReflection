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
        EVReflection.setBundleIdentifier(TestObject.self)
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
        print("\(status.toJsonString())")
        XCTAssertTrue(status.nullableType == 1, "the nullableType should be 1")
        XCTAssertTrue(status.enumType == .notOK, "the status should be NotOK")
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
        XCTAssertTrue(status.enumType == .notOK, "the status should be NotOK")
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
        event.enumList.append(.ok)
        event.enumList.append(.ok)
        event.enumList.append(.notOK)
        event.enumList.append(.ok)
        event.structType = CGPoint(x: 2, y: 3)
        
        let json = event.toJsonString()
        print("json = \(json)")
        
        let newEvent = WorkaroundObject(json:json)
        XCTAssertEqual(newEvent.structType.x, 2, "The location x should have been 2")
        XCTAssertEqual(newEvent.structType.y, 3, "The location y should have been 3")
    }
    
    func testEnumArray() {
        let event = WorkaroundObject()
        event.enumList.append(.ok)
        event.enumList.append(.ok)
        event.enumList.append(.notOK)
        event.enumList.append(.ok)
        
        let json = event.toJsonString()
        print("json = \(json)")

        XCTAssert(!json.contains("EVReflection_iOS_Tests.StatusType.ok"), "The rawvalue should have been in the json.")
        let event2 = WorkaroundObject(json: json)
        print(event2)
        
        //TODO: This is a Swift 3 bug for which I don't have a workaround (yet?)
        //See https://bugs.swift.org/browse/SR-3083
        //this is failing because Mirror is returning the displayStyle .class for the items in the array instead of displayStyle .enum.
        XCTAssertEqual(event.enumList.count, event2.enumList.count, "Now the list should also have 4 items")
        if event2.enumList.count == 4 {
            XCTAssertEqual(event2.enumList[0], StatusType.ok, "The first item should be .OK")
            XCTAssertEqual(event2.enumList[1], StatusType.ok, "The first item should be .OK")
            XCTAssertEqual(event2.enumList[2], StatusType.notOK, "The first item should be .NotOK")
            XCTAssertEqual(event2.enumList[3], StatusType.ok, "The first item should be .OK")            
        }
    }
    
    func testXX() {
        let a = [StatusType.notOK]
        let b = Mirror(reflecting: a)
        let c = b.subjectType
        print("subjectType = \(c)")
        let d = b.displayStyle
        print("displayStyle = \(d)")
    }
}


@objc enum StatusType: Int, EVRawInt {
    case notOK = 0
    case ok = 1
}


class WorkaroundObject: EVObject, EVArrayConvertable {
    var nullableType: Int?
    var enumType: StatusType = .ok
    var enumList: [StatusType] = []
    var list: [WorkaroundObject?] = [WorkaroundObject?]()
    var dict: [String: SubObject] = [:]
    var structType: CGPoint = CGPoint(x: 0, y: 0)
    
    // Handling the setting of non key-value coding compliant properties
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key {
        case "nullableType":
            nullableType = value as? Int
        case "enumType":
            if let rawValue = value as? Int {
                if let status =  StatusType(rawValue: rawValue) {
                    self.enumType = status
                }
            }
        case "enumList":
            if let enumList = value as? NSArray {
                self.enumList = []
                for item in enumList {
                    if let rawValue = item as? NSNumber, let statusType = StatusType(rawValue: Int(rawValue)) {
                        self.enumList.append(statusType)
                    }
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
                    self.dict[key as? String ?? ""] = SubObject(dictionary: value as! NSDictionary)
                }
            }
        case "structType":
            if let dict = value as? NSDictionary {
                if let x = dict["x"] as? NSNumber, let y = dict["y"] as? NSNumber {
                    structType = CGPoint(x: CGFloat(x), y: CGFloat(y))
                }
            }
        default:
            self.addStatusMessage(.IncorrectKey, message: "SetValue for key '\(key)' should be handled.")
            print("---> setValue for key '\(key)' should be handled.")
        }
    }
    
    // Implementation of the EVArrayConvertable protocol for handling an array of nullble objects.
    func convertArray(_ key: String, array: Any) -> NSArray {
        assert(key == "list" || key == "enumList", "convertArray for key \(key) should be handled.")

        let returnArray = NSMutableArray()
        if key == "list" {
            for item in (array as? [WorkaroundObject?]) ?? [WorkaroundObject?]() {
                if item != nil {
                    returnArray.add(item!)
                }
            }
        } else {
            for item in  (array as? [StatusType]) ?? [StatusType]() {
                returnArray.add(item.rawValue)
            }
        }
        return returnArray
    }

    // Implementation of the EVDictionaryConvertable protocol for handling a Swift dictionary.
    func convertDictionary(_ field: String, dict: Any) -> NSDictionary {
        assert(field == "dict", "convertDictionary for key \(field) should be handled.")
    
        let returnDict = NSMutableDictionary()
        for (key, value) in dict as? NSDictionary ?? NSDictionary() {
            returnDict[key as? String ?? ""] = SubObject(dictionary: value as? NSDictionary ?? NSDictionary())
        }
        return returnDict
    }
}
