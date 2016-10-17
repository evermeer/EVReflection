//
//  EVReflectionIssue114b.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 08/10/2016.
//  Copyright © 2016 evict. All rights reserved.
//


import Foundation
import XCTest

@testable import EVReflection


class TestIssue114b: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(User.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue114b() {
        let jsonDictOriginal: NSDictionary = [
            "id": 24,
            "name": "John Appleseed",
            "email": "john@appleseed.com",
            "company": [
                "name": "Apple",
                "address": "1 Infinite Loop, Cupertino, CA"
            ],
            "friends": [
                ["id": 27, "name": "Bob Jefferson"],
                ["id": 29, "name": "Jen Jackson"]
            ]
        ]
        print("Initial dictionary:\n\(jsonDictOriginal)\n\n")
        
        let userOriginal = User114(dictionary: jsonDictOriginal)
        print("object description: \n\(userOriginal)\n\n")
        
        let jsonString = userOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")
        
        XCTAssert(userOriginal.friends.count == 2)
    }
    
    
    class User114: EVObject {
        var id: Int = 0
        var name: String = ""
        var email: String?
        var company: Company114 = Company114()
        var friends: [User114] = []
    }
    
    class Company114: EVObject {
        var name: String = ""
        var address: String?
    }
    
    func testIssueNestedObjects() {
        let x = User114()
        print("type 1 = \(NSStringFromClass(type(of: x.company)))") // output = type 2 = _TtCC22EVReflection_iOS_Tests13TestIssue114b10Company114
        print("type 2 = \(testIssueNestedObjects(x.friends))")
        
    }
    
    func testIssueNestedObjects(_ theValue: Any) -> String {
        var valueType = ""
        let mi = Mirror(reflecting: theValue)
        valueType = String(reflecting: type(of:theValue))
        valueType = String(describing: type(of:theValue)) // Array<User114>
        valueType = (theValue as! [NSObject]).getTypeAsString() // NSObject
        valueType = NSStringFromClass(type(of: (theValue as! [NSObject]).getTypeInstance() as NSObject))  //  NSObject
        valueType = "\(type(of: theValue))"   // Array<User114>
        valueType = "\(mi.subjectType)"      // Array<User114>
        valueType = ObjectIdentifier(mi.subjectType).debugDescription //"ObjectIdentifier(0x0000000118b4a0d8)"
        valueType = (theValue as AnyObject).debugDescription      // <Swift._EmptyArrayStorage 0x10d860b50>
        valueType = NSStringFromClass(type(of: theValue as AnyObject)) // Swift._EmptyArrayStorage
        // set breakpont en enter this in output window: (lldb) po type(of: theValue)
        // Ouput will be: Swift.Array<EVReflection_iOS_Tests.TestIssue114b.User114>
        return valueType
    }
}


//EVReflection_iOS_Tests.TestIssue114b.User114
//_TtCC22EVReflection_iOS_Tests13TestIssue114b7User114

