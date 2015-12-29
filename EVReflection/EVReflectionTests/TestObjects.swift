//
//  TestObject.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import CoreGraphics

@testable import EVReflection

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
    var objectValue2: String?
}

/**
Variant of TestObject2 to test that they are not equal
*/
public class TestObject2b {
    var objectValue: String = ""
}


/**
For testing the automatic conversion from and to string and int
*/
public class TestObject4: EVObject {
    var myString: String = ""
    var myFloat: Float = 0
    var myDouble: Double = 0
    var myBool: Bool = true
    var myDate: NSDate = NSDate()
    var myInt: Int = 0
    var myInt8: Int8 = 0
    var myInt16: Int16 = 0
    var myInt32: Int32 = 0
    var myInt64: Int64 = 0
    var myUInt: UInt = 0
    var myUInt8: UInt8 = 0
    var myUInt16: UInt16 = 0
    var myUInt32: UInt32 = 0
    var myUInt64: UInt64 = 0
    var myNSNumber: NSNumber?
    var invalid_character: String?
    var list: [TestObject4] = []
    var myAny: Any?
    var myAnyObject: AnyObject?
    var rect: CGRect?
    var array: [TestObject2] = [TestObject2(), TestObject2()]
    var array2: NSMutableArray = NSMutableArray()
    var array3: [String] = ["test"]
    var array4: [TestObject2] = []
    var array5: [TestObject2?]? = [TestObject2(), nil, TestObject2()]
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
            NSLog("WARNING: setValue for key '\(key)' should be handled.")
        }
    }
}


/**
 Variant of TestObject2 to show automatic property mapping
 */
public class TestObject2c: NSObject {
    var objectValue: String = ""
    var _default: String?
}


/**
For testing the custom property maping
*/
public class TestObject5: EVObject {
    var Name: String = "" // Using the default mapping
    var propertyInObject: String = "" // will be written to or read from keyInJson
    var ignoredProperty: String = "" // Will not be written or read to/from json 
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("ignoredProperty",nil), ("propertyInObject","keyInJson")]
    }
}


/**
For testing the custom property conversion
*/
public class TestObject6: EVObject {
    var isGreat: Bool = false
    
    override public func propertyConverters() -> [(String?, (Any?)->(), () -> Any? )] {
        return [
            ( // We want a custom converter for the field isGreat
              "isGreat"
              // isGreat will be true if the json says 'Sure'
              , { self.isGreat = ($0 as? String == "Sure") }
              // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
              , { return self.isGreat ? "Sure": "Nah"})]
    }
}


/**
 For testing objects with arrays
 */

class ArrayObjects: NSObject {
    var strings:[String] = ["a","b"]
    var dates:[NSDate] = [NSDate(), NSDate()]
    var arrays:[[String]] = [["a","b"],["c","d"]]
    var dictionaries:[NSDictionary] = [NSDictionary(), NSDictionary()]
    var subobjects:[SubObject] = [SubObject(), SubObject()]
}

class SubObject: EVObject {
    var field:String = "x"
}


public class Circular1: EVObject {
    var normalProperty: String? = ""
    var startCircle: Circular2?
}

public class Circular2: EVObject {
    var anotherNormalProperty: String? = ""
    var createCircle: Circular1?
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("createCircle", nil)]
    }
}

