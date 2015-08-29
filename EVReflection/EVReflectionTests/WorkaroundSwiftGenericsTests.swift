//
//  SwiftGenericsBug.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 8/10/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest


/**
Testing the workaround for generics.
*/
class WorkaroundSwiftGenericsTests: XCTestCase {
    func testGenericsJson() {
        let json:String = "{\"test\":\"test\", \"data\":\"data\", \"array\":[\"val1\",\"val2\",\"val3\"]}"
        let a = MyGenericObject<NSString>(json: json)
        XCTAssertEqual(a.test, "test", "test should contain test")
        XCTAssertEqual(a.data as String, "data", "data should contain data")
        XCTAssertEqual(a.array.count, 3, "data should contain data")
    }

    func testGenericsJson2() {
        let json:String = "{\"test\":\"test\", \"data\":{\"name\":\"data\"}, \"array\":[{\"name\":\"val1\"}, {\"name\":\"val2\"}, {\"name\":\"val3\"}]}"
        let a = MyGenericObject<InstanceObject>(json: json)
        XCTAssertEqual(a.test, "test", "test should contain test")
        XCTAssertEqual(a.data.name!, "data", "data.name should contain data")
        XCTAssertEqual(a.array.count, 3, "array should contain 3 elements")
        if a.array.count == 3 {
            XCTAssertEqual(a.array[0].name!, "val1", "array[0].name should contain val1")
            XCTAssertEqual(a.array[1].name!, "val2", "array[1].name should contain val2")
            XCTAssertEqual(a.array[2].name!, "val3", "array[2].name should contain val2")
        }
    }
}


// Only put the generic properties in this class. put the rest in a base class
// Add the protocol EVGenericsKVC so that we still can have a setValue forUndefinedKey like we adr used to
public class MyGenericObject<T where T:NSObject>: MyGenericBase, EVGenericsKVC {
    var data: T = T()
    var array: [T] = [T]()
    
    required public init() {
        super.init()
    }
    
    override public func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "data":
            data = value as! T
        case "array":
            array = value as! [T]
        default:
            print("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
}

// Put the rest of the properties in a base class like this. Otherwise you have to handle each in the setValue forUndefinedKey
public class MyGenericBase: EVObject {
    var test : String = ""
}

public class InstanceObject: EVObject {
    var name:String?
}

