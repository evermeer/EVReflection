//
//  TestObject3.swift
//
//  Created by Edwin Vermeer on 5/8/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

class TestObject3:EVObject {
    var objectValue:String = ""
    var nullableType:Int?
    
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