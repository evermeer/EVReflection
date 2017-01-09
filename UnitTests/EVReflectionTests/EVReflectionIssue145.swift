//
//  EVReflectionIssue145.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 22/12/2016.
//  Copyright © 2016 evict. All rights reserved.
//


import Foundation
import XCTest

@testable import EVReflection


class TestIssue145: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(User.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue145() {
        let jsonDictOriginal: NSDictionary = [
            "id": 24,
            "name": "John Appleseed",
            "email": "john@appleseed.com",
            "company": [
                "name": "Apple",
                "address": "1 Infinite Loop, Cupertino, CA"
            ],
            "workHistory": [
                ["name": "Google", "address": "1600 Amphitheatre Parkway, Mauntain View"],
                ["name": "Facebook", "address": "1 Hacker Way, Menlo Park"]
            ]
        ]
        print("Initial dictionary:\n\(jsonDictOriginal)\n\n")
        
        let userOriginal = User145a(dictionary: jsonDictOriginal)
        print("object description: \n\(userOriginal)\n\n")
        
        let jsonString = userOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")
        
        let userDictionary = User145b(json: jsonString)
        print("object description with NSDictionary: \n\(userDictionary)\n\n")

        let userAnyObject = User145c(json: jsonString)
        print("object description with AnyObject: \n\(userAnyObject)\n\n")
        
        let finalJson = userAnyObject.toJsonString()
        print("Final JSON string from object with AnyObject: \n\(jsonString)\n\n")
        XCTAssertEqual(jsonString, finalJson, "Json should be the same")
        
        XCTAssert(userOriginal.workHistory?.count == 2)
    }
    
}

class User145a: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: Company145?
    var workHistory: [Company145]?
}

class User145b: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: NSDictionary?
    var workHistory: [NSDictionary]?
}

class User145c: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: AnyObject? = NSDictionary()
    var workHistory: [AnyObject]? = []
}

class Company145: EVObject {
    var name: String = ""
    var address: String?
}
