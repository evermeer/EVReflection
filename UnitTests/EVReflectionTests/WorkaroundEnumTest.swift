//
//  EnumWorkaroundTests.swift
//
//  Created by Edwin Vermeer on 7/23/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import XCTest
@testable import EVReflection


class myClass: NSObject {
    let item: String = ""
}

/**
Testing The enum workaround. Ignore this. Nothing is used in the actual library
*/
class EnumWorkaroundsTests: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(myClass.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnumToRaw() {
        let test1 = getRawValue(MyEnumOne.OK)
        XCTAssertTrue(test1 as? String == "OK-2", "Could nog get the rawvalue using a generic function. As a workaround just add the EVRawString protocol")
        let test2 = getRawValue(MyEnumTwo.ok)
        XCTAssertTrue(test2 as? Int == 1, "Could nog get the rawvalue using a generic function. As a workaround just add the EVRawInt protocol")
        let test3 = getRawValue(MyEnumThree.ok)
        XCTAssertTrue(test3 as? NSNumber == 1, "Could nog get the rawvalue using a generic function. As a workaround just add the EVRaw protocol")
        let varTest4 = MyEnumFour.notOK(message: "realy wrong")
        let test4 = getRawValue(varTest4) as? String
        XCTAssertTrue(varTest4.associated.label == "notOK", "Could nog get the associated value using a generic function")
        XCTAssertTrue(test4 == "realy wrong", "Could nog get the associated value using a generic function")
        let varTest5 = MyEnumFour.ok(level: 3)
        let test5 = getRawValue(varTest5) as? Int
        XCTAssertTrue(varTest5.associated.label == "ok", "Could nog get the rawvalue using a generic function")
        XCTAssertTrue(test5 == 3, "Could nog get the associated value using a generic function")
        let test6 = getRawValue(MyEnumFive.ok)
        XCTAssertTrue(test6 as? String == "ok", "So we could get the raw value? Otherwise this would fail")
    }
    
    func testArrayNullable() {
        var testArray: [myClass?] = [myClass]()
        testArray.append(myClass())
        testArray.append(nil)
        let newArray: [myClass] = (testArray.filter { $0 != nil }) as! [myClass]
        XCTAssertTrue(newArray.count == 1, "We should have 1 object in the array")
    }
    
    func testArrayNotNullable() {
        var testArray: [myClass] = [myClass]()
        testArray.append(myClass())
        let newArray: [myClass] = (testArray.filter { $0 != nil })  // Yes, you will ge a warning, but we do have to test this. reflection could have messed things up
        XCTAssertTrue(newArray.count == 1, "We should have 1 object in the array")
    }
    
    func testNotAssociated() {
        NSLog("\n\n==>You will get a warning because MyEnumOne.OK does not have an associated value")
        let a = MyEnumOne.OK.associated
        XCTAssertNil(a.value, "Associated value should be nil")
    }
    
    enum MyEnumOne: String, EVRaw, EVAssociated {      // Add , EVRawString to make the test pass
        case NotOK = "NotOK-1"
        case OK = "OK-2"
    }
    
    enum MyEnumTwo: Int, EVRaw {       // Add , EVRawInt to make the test pass
        case notOK = 0
        case ok = 1
    }
    
    enum MyEnumThree: Int64, EVRaw {   // Add , EVRaw to make the test pass
        case notOK = 0
        case ok = 1
    }
    
    enum MyEnumFour: EVAssociated {
        case notOK(message: String)
        case ok(level: Int)
    }
    
    enum MyEnumFive: Int {
        case notOK = 0
        case ok = 1
    }
    
    func getRawValue(_ theEnum: Any) -> Any {        
        let (val, _, _) = EVReflection.valueForAny(self, key: "a", anyValue: theEnum)
        return val
    }
    
    func testEnumWrapper() {
        let z = Z()
        z.x = EnumWrapper(X.A)
        let json = z.toJsonString()
        print(json)
        let z2 = Z(json: json)
        print(z2)
        XCTAssert(z2.x.rawValue as? String ?? "" == X.A.rawValue, "New value should also be X.A")
    }
}



public class Z : EVObject {
    var x: EnumWrapper = EnumWrapper(X.B)
}

public enum X: String, EVRaw {
    case A,
    B
}


public class EnumWrapper: NSObject, EVCustomReflectable {
    
    var value: EVRaw?
    var raw : Any?
    
    var rawValue: Any? {
        return (value?.anyRawValue ?? raw)
    }
    
    public init(_ value: EVRaw) {
        self.value = value
    }
    
    public func constructWith(value: Any?) {
        self.value = nil
        self.raw = value
    }
    
    public func toCodableValue() -> Any {
        return (value?.anyRawValue ?? raw)!
    }
}

