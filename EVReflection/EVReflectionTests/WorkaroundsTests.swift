//
//  EnumTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 7/23/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest


/**
Testing The 3 propery types that need a workaround.
*/
class WorkaroundsTests: XCTestCase {
    
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
        let json:String = "{\"nullableType\": 1,\"enumType\": 0, \"list\": [ {\"nullableType\": 2}, {\"nullableType\": 3}] }"
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
        let initialJson:String = "{\"nullableType\": 1,\"enumType\": 0, \"list\": [ {\"nullableType\": 2}, {\"nullableType\": 3}] }"
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
    
}


//
class WorkaroundObject: EVObject, EVArrayConvertable {
    
    enum StatusType: Int, EVRawInt {
        case NotOK = 0
        case OK = 1
    }
    
    var nullableType: Int?
    var enumType: StatusType = .OK
    var list: [WorkaroundObject?] = [WorkaroundObject?]()
    
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
        default:
            print("---> setValue for key '\(key)' should be handled.")
        }
    }
    
    // Implementation of the EVArrayConvertable protocol for handling an array of nullble objects.
    func convertArray(key: String, array: Any) -> NSArray {
        switch key {
            case "list":
                let returnArray = NSMutableArray()
                for item in array as! [WorkaroundObject?] {
                    if item != nil {
                        returnArray.addObject(item!)
                    }
                }
                return returnArray
        default:
            print("---> convertArray for key \(key) should be handled.")
            return NSArray()
        }
    }
}






