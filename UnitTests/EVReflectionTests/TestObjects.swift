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
open class TestObject: NSObject {
    var objectValue: String = ""
}


/**
Second test object where the base class is an EVObject so that we have support for the protocols NSObject, NSCoding, Printable, Hashable, Equatable plus convenience methods.
*/
open class TestObject2: EVObject {
    var objectValue: String = ""
    var objectValue2: String?
}

/**
Variant of TestObject2 to test that they are not equal
*/
open class TestObject2b {
    var objectValue: String = ""
}


/**
For testing the automatic conversion from and to string and int
*/
open class TestObject4: EVObject, EVArrayConvertable {
    var myString: String = ""
    var myFloat: Float = 0
    var myDouble: Double = 0
    var myBool: Bool = true
    var myDate: Date = Date()
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
    
    // Implementation of the EVArrayConvertable protocol for handling an array of nullble objects.
    open func convertArray(_ key: String, array: Any) -> NSArray {
        assert(key == "array5", "convertArray for key \(key) should be handled.")
        
        let returnArray = NSMutableArray()
        for item in array as? [TestObject2?] ?? [TestObject2?]() {
            if item != nil {
                returnArray.add(item!)
            }
        }
        return returnArray
    }
}



/**
 Third test object where you can see how create a workaround for the swift limitation with setting a value for a key where the property is a nullable type.
 */
class TestObject3: EVObject {
    var objectValue: String = ""
    var nullableType: Int?
    
    // This construction can be used to bypass the issue for setting a nullable type field
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
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
open class TestObject2c: EVObject {
    var objectValue: String = ""
    var _default: String?
}






class TestObject8: EVObject {
    var containers: [TestObject8Container] = []
}

class TestObject8Container: EVObject {
    var rows: [TestObject8Row] = []
}

class TestObject8Row: EVObject {
    var kind: String?
}


/**
 For testing objects with arrays
 */

class ArrayObjects: EVObject {
    var strings: [String] = ["a","b"]
    var dates: [Date] = [Date(), Date()]
    var arrays: [[String]] = [["a","b"], ["c","d"]]
    var dictionaries: [NSDictionary] = [NSDictionary(), NSDictionary()]
    var subobjects: [SubObject] = [SubObject(), SubObject()]
    var nilObjects: [SubObject]?
    var nilStrings: [String]?
    var nilObjectsForced: [SubObject]!
    var nilStringsForced: [String]!
}

class SubObject: EVObject {
    var field: String = "x"
}


open class Circular1: EVObject {
    var normalProperty: String? = ""
    var startCircle: Circular2?
}

open class Circular2: EVObject {
    var anotherNormalProperty: String? = ""
    var createCircle: Circular1?
}

open class TestObject7: EVObject {
    var subOne: SubObject?
    var subTwo: SubObject?
}

open class TestObjectWithNilConverters: EVObject {
    
    var optionalValue: String?
    
    override open func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [(key: "optionalValue", decodeConverter: {_ in }, encodeConverter: { return nil})]
    }
}

class DicTest: EVObject {
    var dict: [String:String] = ["t":"bar"]
    required init() {
    }
}

open class AA: EVObject {
    open var bs: [BB] = []
}

open class BB: EVObject {
    open var val: Int = 0
}

class NestedArrays: EVObject {
    var date: NSNumber?
    var results: NestedArraysResult?
    var unit: String?
}

class NestedArraysResult: EVObject {
    var planets = [String: [[NSNumber]]]()
    
    // This way we can solve that the JSON has arbitrary keys
    internal override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let a = value as? [[NSNumber]] {
            planets[key] = a
            return
        }
        NSLog("---> setValue for key '\(key)' should be handled.")
    }
}

open class ValidateObject: EVObject {
    var requiredKey1: String?
    var requiredKey2: String?
    var requiredKey3: String?
    var optionalKey1: String?
    var optionalKey2: String?
    var optionalKey3: String?
    
    open override func initValidation(_ dict: NSDictionary) {
        self.initMayNotContainKeys(["error"], dict: dict)
        self.initMustContainKeys(["requiredKey1", "requiredKey2", "requiredKey3"], dict: dict)
        if dict.value(forKey: "requiredKey1") as? String == dict.value(forKey: "optionalKey1") as? String {
            // this could also be called in your property specific validators
            self.addStatusMessage(.Custom, message: "optionalKey1 should not be the same as requiredKey1")
        }
    }
    
    func validateOptionalKey3(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        if let theValue = value.pointee as? String {
            if theValue.lengthOfBytes(using: String.Encoding.utf8) < 3 {
                self.addStatusMessage(.InvalidValue, message: "optionalKey3 should be at least 3 characters long: '\(value)'")
                throw MyValidationError.lengthError
            }
        } else {
            self.addStatusMessage(.InvalidValue, message: "optionalKey3 should be string instead of '\(value)'")
            throw MyValidationError.typeError
        }
    }
}

class ImLazy: EVObject {
    lazy var lazyInt: Int = 0
    lazy var LazyString: String = ""
}

open class NestedIUOObject: EVObject {
    var property1: Int = 0
    var property2: Int = 0
}

open class NestedIUOObjectParent: EVObject {
    var iuoObject: NestedIUOObject!
    var control: String?
}

open class NestedIUOObjectsArrayParent: EVObject {
    var iuoObjects: [NestedIUOObject]!
    var control: String?
}

class MKPolygon: NSObject { }
extension MKPolygon: EVReflectable { }


class A81a: EVObject {
    var array: [A81] = []
}

//TODO: fix nested array bug
class A81b: EVObject {
    var array: [[A81]] = [[]]
    
    // Now only working using this workaround
    // Failure should be fixed for https://github.com/evermeer/EVReflection/issues/212
    override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [(key: "array",
                 decodeConverter: {
                    self.array = (($0 as? NSArray)?.map { (($0 as? NSArray)?.map { A81(dictionary: ($0 as? NSDictionary ?? NSDictionary()))}) ?? [] }) ?? [[]]
        }, encodeConverter: { return self.array })]
    }
}

class A81c: EVObject {
    var array: [[[A81]]] = [[[]]]

    // Now only working using this workaround
    // Failure should be fixed for https://github.com/evermeer/EVReflection/issues/212
    override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [(key: "array",
                 decodeConverter: {
                    self.array = (($0 as? NSArray)?.map { (($0 as? NSArray)?.map { (($0 as? NSArray)?.map { A81(dictionary: ($0 as? NSDictionary ?? NSDictionary()))}) ?? [] }) ?? [[]] }) ?? [[[]]]
        }, encodeConverter: { return self.array })]
    }
}

class A81: EVObject {
    var openId: String = ""
}


class MyObject : EVObject {
    var id : Int = 0
    var active: Bool = false
}


// Swift bug, class inside class works, class inside struct does not work.
public class CogDirect {
    public class Modules {
    }
    public class Model {
        
        class Model : EVObject {
            // this part is just to circumvent having to use enums
            public static let STATUS : [NSString] = [
                "success",
                "failed",
                "unset"
            ]
            
            public static let STATUS_SUCCESS : Int = 0
            public static let STATUS_FAILED = 1
            public static let STATUS_UNSET = 2
            // end
            
            public var status : NSString = STATUS[STATUS_UNSET]
            public var subject : NSString = "unset"
            public var message : NSString = ""
        }
        
        
        class BeaconModel : EVObject {
            public var uuid : NSString = ""
            public var major : Int = -1
            public var minor : Int = -1
            public var accuracy : Double = -1
        }
        
        class BeaconsModel : Model {
            public var beacons : [BeaconModel] = [] // this part is not key-value coding compliant
        }
    }
}
