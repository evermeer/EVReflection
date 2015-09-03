//
//  EnumWorkaroundTests.swift
//
//  Created by Edwin Vermeer on 7/23/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest


class myClass: NSObject {
    let item:String = ""
}

/**
Testing The enum workaround. Ignore this. Nothing is used in the actual library
*/
class EnumWorkaroundsTests: XCTestCase {
    
    func testEnumToRaw() {
        let test1 = getRawValue(MyEnumOne.OK)
        XCTAssertTrue(test1 as? String == "OK-2", "Could nog get the rawvalue using a generic function")
        let test2 = getRawValue(MyEnumTwo.OK)
        XCTAssertTrue(test2 as? Int == 1, "Could nog get the rawvalue using a generic function")
        let test3 = getRawValue(MyEnumThree.OK)
        XCTAssertTrue(test3 as? Int64 == 1, "Could nog get the rawvalue using a generic function")
        let test4 = getRawValue(MyEnumFour.NotOK(message: "realy wrong")) as? (String?, [protocol<>])
        XCTAssertTrue(test4?.0 == "NotOK", "Could nog get the rawvalue using a generic function")
        XCTAssertTrue(test4?.1.first as? String == "realy wrong", "Could nog get the associated value using a generic function")
        let test5 = getRawValue(MyEnumFour.OK(level: 3)) as? (String?, [protocol<>])
        XCTAssertTrue(test5?.0 == "OK", "Could nog get the rawvalue using a generic function")
        XCTAssertTrue(test5?.1.first as? Int == 3, "Could nog get the associated value using a generic function")
    }
    
    func testArrayNullable() {
        var testArray: [myClass?] = [myClass]()
        testArray.append(myClass())
        testArray.append(nil)
        let newArray: [myClass] = parseArray(testArray) as! [myClass]
        XCTAssertTrue(newArray.count == 1, "We should have 1 object in the array")
    }
    
    func parseArray(array:Any) -> AnyObject {
        if let arrayObject: AnyObject = array as? AnyObject {
            return arrayObject
        }
        print("array was not an AnyObject")
        var temp = [AnyObject]()
        for item in (array as! [myClass?]) {
            if item != nil {
                temp.append(item!)
            }
        }
        return temp
    }
    
    enum MyEnumOne: String {      // Add , EVRawString to make the test pass
        case NotOK = "NotOK-1"
        case OK = "OK-2"
    }
    
    enum MyEnumTwo: Int {       // Add , EVRawInt to make the test pass
        case NotOK = 0
        case OK = 1
    }
    
    enum MyEnumThree: Int64 {   // Add , EVRaw to make the test pass
        case NotOK = 0
        case OK = 1
        var anyRawValue: Any { get { return self.rawValue }}
    }
    
    enum MyEnumFour {
        case NotOK(message: String)
        case OK(level: Int)
    }
    
    func getRawValue(theEnum: Any) -> Any {
        // What can we get using reflection:
        let mirror = Mirror(reflecting: theEnum)

        let valueType:Any.Type = mirror.subjectType
        print("valueType = \(valueType)")
        // No help from these:
        let description = mirror.description  // --> "Mirror for MyEnumOne"
        print("description = \(description)")
        let displayStyle = mirror.displayStyle  // --> Enum
        print("displayStyle = \(displayStyle)")
        
        let subjectType = mirror.subjectType // EVReflectionTests.EnumWorkaroundsTests.MyEnumOne
        print("subjectType = \(subjectType)")
        let toString:String = "\(theEnum)"
        print("String value: \(toString)\n")

        if mirror.displayStyle == .Enum {
            print("displayStyle is .Enum")

            let count = mirror.children.count  // --> 0
            print("children.count = \(count)")
            if mirror.children.count > 0 {
                for child in mirror.children {
                    print("child.label = \(child.label), child.value = \(child.value)")
                }
                return (mirror.children.first?.label, mirror.children.map({$0.value}))
            }
            
            
            // OK, and now?
            
            // Thees do not complile:
            //return enumRawValue(rawValue: theEnum)
            //return enumRawValue2(theEnum )
            
            if let value = theEnum as? EVRawString {
                return value.rawValue
            }
            if let value = theEnum as? EVRawInt {
                return value.rawValue
            }
            if let value = theEnum as? EVRaw {
                return value.anyRawValue
            }
            print("For now you have to implement one of the EVRaw protocols on your enum. ")
        }
        return toString
    }
    
    func enumRawValue<E: RawRepresentable>(rawValue: E.RawValue) -> String {
        let value = E(rawValue: rawValue)?.rawValue
        return "\(value)"
    }
    
    func enumRawValue2<T:RawRepresentable>(rawValue: T) -> String {
        return "\(rawValue.rawValue)"
    }
    
}



