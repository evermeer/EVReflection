//
//  EVReflectionIssue99.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 6/27/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest
@testable import EVReflection

public class Message: EVObject, EVDictionaryConvertable {
    var body: String? = ""
    var email: String? = ""
    var subject: String? = "Message"
    var sysId: String? = "7b68dea1-c8b1-46b5-9556-21bf013635c7"
    var user: String? = ""
    var threadId: String? = ""
    var users: [String:String] = [String:String]()
    
    // Handling the setting of non key-value coding compliant properties
    override public func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "users":
            if let dict = value as? NSDictionary {
                self.users = [:]
                for (key, value) in dict {
                    self.users[key as? String ?? ""] = (value as? String)
                }
            }
        default:
            print("---> setValue for key '\(key)' should be handled.")
        }
    }

    
    public func convertDictionary(key: String, dict: Any) -> NSDictionary {
        assert(key == "users", "convertArray for key \(key) should be handled.")
        
        let returnDict = NSMutableDictionary()
        for (key, value) in dict as? NSDictionary ?? NSDictionary() {
            returnDict[key as? String ?? ""] = value
        }
        return returnDict
    }
}

class TestIssue99: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Message)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue99() {
        let m = Message()
        m.users["user1"] = "user data 1"
        let dic = m.toDictionary()
        print(dic)
    }
    
}
