//
//  EVReflectionIssueAF39.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 07/02/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import XCTest
@testable import EVReflection


/**
 Testing the workaround for generics.
 */
class EVReflectionIssueAF39: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(ApiGenericBase39.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGenericsJson() {
        let json: String = "{\"success\":11, \"message\":\"test\", \"data\":[{\"uuid\":\"id1\"}, {\"uuid\":\"id2\"}]}"
        let a = ApiResponse<Vehicle>(json: json)
        print("object = \(a)")
        XCTAssertEqual(a.success, 11, "success should contain 11")
        XCTAssertEqual(a.message, "test", "message should contain test")
        XCTAssertEqual(a.data.count, 2, "array should contain 3 elements")
        if a.data.count == 2 {
            XCTAssertEqual(a.data[0].uuid, "id1", "array[0].name should contain val1")
            XCTAssertEqual(a.data[1].uuid, "id2", "array[1].name should contain val2")
        }
    }
    
    func testGenericsJson2() {
        let json: String = "{\"success\":11, \"message\":\"test\", \"data\":{\"uuid\":\"id1\"}}"
        let a = ApiResponse<Vehicle>(json: json)
        print("object = \(a)")
        XCTAssertEqual(a.success, 11, "success should contain 11")
        XCTAssertEqual(a.message, "test", "message should contain test")
        XCTAssertEqual(a.data.count, 1, "array should contain 3 elements")
        if a.data.count == 2 {
            XCTAssertEqual(a.data[0].uuid, "id1", "array[0].name should contain val1")
        }
    }

    func testGenericsJson3() {
        let json: String = "{\"success\":11, \"message\":\"test\", \"data\":{\"someField\":\"value1\"}}"
        let a = ApiResponse<RandomObject>(json: json)
        print("object = \(a)")
        XCTAssertEqual(a.success, 11, "success should contain 11")
        XCTAssertEqual(a.message, "test", "message should contain test")
        XCTAssertEqual(a.data.count, 1, "array should contain 3 elements")
        if a.data.count == 2 {
            XCTAssertEqual(a.data[0].someField, "value1", "array[0].name should contain val1")
        }
    }
}

open class ApiGenericBase39: EVNetworkingObject {
    var success: NSNumber?
    var message: String?
    var status_code: String?
}

open class ApiResponse<T>: ApiGenericBase39, EVGenericsKVC where T:NSObject {
    var data: [T] = [T]()
    
    public func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "data":
            data = value as? [T] ?? [T]()
        default:
            print("---> setGenericValue '\(value ?? [] as AnyObject)' forUndefinedKey '\(key)' should be handled.")
        }
    }
    
    public func getGenericType() -> NSObject {
        return T()
    }
}

public class Vehicle: EVNetworkingObject {
    var uuid: String?
}

public class RandomObject: EVNetworkingObject {
    var someField: String?
}

