//
//  TestObject.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation

/**
First test object where the base class is just an NSObject
*/
public class TestObject: NSObject {
    var objectValue: String = ""
}


/**
Second test object where the base class is an EVObject so that we have support for the protocols NSObject, NSCoding, Printable, Hashable, Equatable plus convenience methods.
*/
public class TestObject2: EVObject {
    var objectValue: String = ""
}


/**
Third test object where you can see how create a workaround for the swift limitation with setting a value for a key where the property is a nullable type.
*/
class TestObject3: EVObject {
    var objectValue: String = ""
    var nullableType: Int?
    
    // This construction can be used to bypass the issue for setting a nullable type field
    override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "nullableType":
            nullableType = value as? Int
        default:
            NSLog("---> setValue for key '\(key)' should be handled.")
        }
    }
}