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
    
    // Issue reported in AlamofireJsonToObjects
    func testIssue24() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        EVReflection.setDateFormatter(dateFormatter)
        
        let json = "[{ \"positiveResponsePercentage\" : 80, \"Description\" : \"The description\", \"myPrimaryObjectId\" : \"ADSF13\", \"numberOfOccurrences\" : 2, \"name\" : \"The name\", \"secondaryObjects\" : [ { \"rating\" : 9, \"dateRecorded\" : \"20160620\", \"mySecondaryObjectId\" : 1, \"userRemarks\" : \"The remarks\" }, { \"rating\" : 8, \"dateRecorded\" : \"20160515\", \"mySecondaryObjectId\" : 2, \"userRemarks\" : \"More remarks\" }]}]"
        let x = [MyPrimaryObject](json: json)
        let json2 = x.toJsonString()
        print(json2)
    }
    
    
    func testIssue24b() {
        //I modified the PublicInfusion.vodkaHistory to be empty instead of nil.  Which is different from my original example
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        EVReflection.setDateFormatter(dateFormatter)
        
        //test 1 - PublicInfusion (MyPrimaryObject)
        //show PublicInfusion without array of secondary objects
        //result: working
        
        let testJson1 = "[{\"InfusionKey\":\"3b7f1f65-937e-4901-8f9c-6ea4d8c0890f\",\"InfusionId\":98,\"Name\":\"Almond\",\"Description\":null,\"InfusionDrinkCount\":2,\"InfusionLikedPercentage\":0.0,\"VodkaHistory\":[]}]"
        
        let x1 = [PublicInfusion](json: testJson1)
        let json1 = x1.toJsonString()
        print(json1)
        
        //test 2 - PublicInfusionCheckmark (MySecondaryObject)
        //show PublicInfusionCheckmark as a separate array
        //result: working
        let testJson2 = "[{\"CheckmarkId\":1,\"DateMarked\":\"2016-06-04T00:03:04.433\",\"VodkaRating\":1,\"Comments\":\"Tastes like marzipan.\"}]"
        
        let x2 = [PublicInfusionCheckmark](json: testJson2)
        let json2 = x2.toJsonString()
        print(json2)
        
        //test 3 - All together now
        //Tests parsing them together as they would normally come from the server
        //result: fatal error
        let testJson3 = "[{\"InfusionKey\":\"3b7f1f65-937e-4901-8f9c-6ea4d8c0890f\",\"InfusionId\":98,\"Name\":\"Almond\",\"InfusionDrinkCount\":2,\"InfusionLikedPercentage\":0.0,\"VodkaHistory\":[{\"CheckmarkId\":1,\"DateMarked\":\"2016-06-04T00:03:04.433\",\"VodkaRating\":1,\"Comments\":\"Tastes like marzipan.\"}]}]"
        
        let x3 = [PublicInfusion](json: testJson3)
        let json3 = x3.toJsonString()
        print(json3)
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

public class PublicInfusion: EVObject {
    
    public var infusionKey: NSUUID?
    public var infusionId: Int = 0
    public var name: String = ""
    public var infusionDescription: String?
    
    public var infusionDrinkCount: Int = 0
    public var infusionLikedPercentage: Float = 0
    
    public var vodkaHistory: [PublicInfusionCheckmark] = []
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("infusionDescription","Description")]
    }
}

public class PublicInfusionCheckmark: EVObject {
    public var checkmarkId: Int = 0
    public var dateMarked: NSDate?
    public var vodkaRating: Int = 0
    public var comments: String?
}
