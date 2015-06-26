//
//  EVReflectionJsonTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 6/15/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest

/**
Testing EVReflection for Json
*/
class EVReflectionJsonTests: XCTestCase {
    
    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testJsonObject(){
        let jsonDictOriginal = [
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
        
        let userOriginal = User(dictionary: jsonDictOriginal)
        print("Dictionary to an object: \n\(userOriginal)\n\n")

        print("company = \(userOriginal.company)\n")
        var company:Company = userOriginal.company!
        
//        print("------ Problem 1 is that this will crash because it's actually an NSObject ------\n")
//        print("company name = \(company.name)\n")

        
        print("------ Problem 2 is that we still need to ast to NSArray ------\n")
        var friends:NSArray = userOriginal.friends as NSArray
        print("friends = \(friends)\n")
        print("friends count = \(friends.count)\n")

        print("------ Array object are not set...  ------\n")
        print("friend 1 = \(friends[0])\n")
        print("friend 1 full_name = \(friends[0].name)\n")
        
        print("------ And the objects are NSObject. Therefore this will still crash ------\n")
        let jsonString = userOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")

        let userRegenerated = User(json:jsonString)
        print("Object from json string: \n\(userRegenerated)\n\n")
        
        if userOriginal == userRegenerated {
            XCTAssert(true, "Success")
        } else {
            XCTAssert(false, "Faileure")
        }
    }
    
    func testJsonArray() {
        let jsonDictOriginal:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
        let array:[User] = EVReflection.arrayFromJson(User(), json: jsonDictOriginal)
        print("Object array from json string: \n\(array)\n\n")
    }    
}

class User: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: Company?
    var friends: [User] = []
}

class Company: EVObject {
    var name: String = ""
    var address: String?
}

