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
Testing The 3 propery types that need a workaround.
*/
class WorkaroundSwiftGenericsTests: XCTestCase {
    func testGenerics() {
        let json:String = "{\"test\":\"test\", \"data\":\"data\"}"
        let a = MyGenericObject<NSString>(json: json)
        XCTAssertEqual(a.test, "test", "test should contin test")
        XCTAssertEqual(a.data as! String, "data", "data should contin data")
    }
}

// Only put the generic properties in this class. put the rest in a base class
public class MyGenericObject<T where T:NSObject>: MyGenericBase, GenericsKVC {
    var data: T = T()
    
    public func genericSetValue(value: AnyObject, forKey key: String) {
        switch key {
        case "data":
            data = value as! T
        default:
            println("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
}

// Put the rest of the properties in a base class like this. Otherwise you have to handle each in the genericSetValue
public class MyGenericBase: EVObject {
    var test : String = ""
}


