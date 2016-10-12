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
    
    
}




