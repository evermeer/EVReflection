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
class GenericsBugTests: XCTestCase {
    func testGenerics1() {
        let a = A<NSString>()
        a.setValue("test", forKey: "test")
        a.setValue("data" as NSObject, forKey: "data")
        XCTAssertEqual(a.test, "test", "test should contin test")
        XCTAssertEqual(a.data as! String, "data", "data should contin data")
    }
    
    func testGenerics2() {
        let json:String = "{\"test\":\"test\", \"data\":\"data\"}"
        let a = A<NSString>(json: json)
        XCTAssertEqual(a.test, "test", "test should contin test")
        XCTAssertEqual(a.data as! String, "data", "data should contin data")
    }
}

public class A<T where T:NSObject>: GenericsBase {
    var test : String = ""
    var data: T = T()
    
    // Handling the setting of non key-value coding compliant properties
    override public func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "test":
            test = value as! String
        case "data":
            data = value as! T
        default:
            println("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
}

public class GenericsBase: EVObject {
    override public func setValue(value: AnyObject!, forUndefinedKey key: String) {
        println("---> GenericsBase: setValue '\(value)' for key '\(key)' should be handled.")
    }
}
