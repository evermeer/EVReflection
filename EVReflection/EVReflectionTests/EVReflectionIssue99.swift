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

public class Message: EVObject {
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
}

class TestObjectIssue99: EVObject {
    var params: [String: String]?    
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
        let json = m.toJsonString()
        print(json)
    }
    
    func testIssue99_2() {
        let paramsRequest = TestObjectIssue99()
        paramsRequest.params = [
            "foo": "bar",
            "baz": "buzz"
        ]
        print(paramsRequest.toJsonString())
    }
    
    func testIssue24() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        EVReflection.setDateFormatter(dateFormatter)
        
        let json = "[{ \"positiveResponsePercentage\" : 80, \"Description\" : \"The description\", \"myPrimaryObjectId\" : \"ADSF13\", \"numberOfOccurrences\" : 2, \"name\" : \"The name\", \"secondaryObjects\" : [ { \"rating\" : 9, \"dateRecorded\" : \"20160620\", \"mySecondaryObjectId\" : 1, \"userRemarks\" : \"The remarks\" }, { \"rating\" : 8, \"dateRecorded\" : \"20160515\", \"mySecondaryObjectId\" : 2, \"userRemarks\" : \"More remarks\" }]}]"
        let x = [MyPrimaryObject](json: json)
        let json2 = x.toJsonString()
        print(json2)
    }
}


public class MyPrimaryObject: EVObject {
    
    public var myPrimaryObjectId: NSUUID?
    public var name: String = ""
    public var myObjectDescription: String?
    
    public var numberOfOccurrences: Int = 0
    public var positiveResponsePercentage: Float = 0
    
    public var secondaryObjects: [MySecondaryObject]?
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("myObjectDescription","Description")]
        
    }
}

public class MySecondaryObject: EVObject {
    public var mySecondaryObjectId: Int = 0
    public var dateRecorded: NSDate?
    public var rating: Int = 0
    public var userRemarks: String?
}
