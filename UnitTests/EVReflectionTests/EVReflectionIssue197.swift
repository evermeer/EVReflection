//
//  EVReflectionIssue197.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 21/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import XCTest
import EVReflection


class TestIssue197: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Base.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue197() {
        let jsonOriginal = "{\"id\":24,\"details\":[{\"id\":29,\"name\":\"Jen Jackson\"}],\"name\":\"Bob Jefferson\"}"
        
        print("--- Original ----")
        print(jsonOriginal)
        print("  ")
        
        let p = Master(json: jsonOriginal)
        XCTAssertEqual(p.details.count, 1, "There should be 1 detail records")
        
        print("--- Print detail items ----")
        p.details.forEach { print($0.description) }
        print("  ")
        
        
        let jsonNew = p.toJsonString()
        print("--- New with Details without Attributes ----")
        print(jsonNew)
        print("  ")
        
        XCTAssertEqual(jsonOriginal, jsonNew, "The new json should be the same as the old.")
    }
}


open class Master: Base197 {
    var id: Int = 0
    var name: String = ""
    var details = [Detail]()
}

open class Detail: Base197 {
    var id: Int = 0
    var name: String = ""
}



/**
 Object that implements EasyKit object and EVObject. Use this object as your base class
 instead of NSObject and you wil automatically have support for all these protocols.
 */
open class Base197: EVObject  {
    
    /**
     Contains all the attributes that do not have a defined key for an attribute
     */
    fileprivate var attributes: NSMutableDictionary = NSMutableDictionary()
    fileprivate static let kAttributesKey = "attributes"
    
    /**
     Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter value: The value that you wanted to set
     - parameter key: The name of the property that you wanted to set
     */
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        attributes[key] = value
    }
    
}


// MARK: - EKCustomReflectable protocol
extension Base197 : EVCustomReflectable {
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - parameter value: The dictionary that will be converted to an object
     */
    public func constructWith(value: Any?) -> EVCustomReflectable? {
        if let jsonDict = value as? NSDictionary {
            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
        }
        return self
    }
    public static func constructWith(value: Any?) -> EVCustomReflectable? {
        return Base197().constructWith(value: value)
    }
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - returns: Dictionary without custom properties key
     */
    public func toCodableValue() -> Any {
        let dict: NSMutableDictionary = self.toDictionary() as! NSMutableDictionary
        print("--------------")
        print("Before cleanup:")
        print(dict)
        let dict2 = cleanupDict(dict)
        print("After cleanup:")
        print(dict2)
        print("--------------")
        return dict2
    }
    
    /**
     Recursive clean dictionary, sub dictionaries, sub arrays with dictionaries
     
     - returns: Dictionary without custom properties key
     */
    private func cleanupDict(_ dict: NSDictionary) -> NSDictionary {
        let attributesDict: NSMutableDictionary = dict[Base197.kAttributesKey] as? NSMutableDictionary ?? NSMutableDictionary()
        let dictionary: NSMutableDictionary = NSMutableDictionary()
        for (key, value) in dict {
            if let key = key as? String {
                if key  != Base197.kAttributesKey {
                    if let value = value as? NSArray {
                        let array: NSMutableArray = NSMutableArray()
                        for object in value {
                            if let dict = object as? NSDictionary {
                                array.add(cleanupDict(dict))
                            } else {
                                array.add(object)
                            }
                        }
                        dictionary[key] = array
                    } else if let value = value as? NSMutableDictionary {
                        dictionary[key] = cleanupDict(value)
                    } else {
                        dictionary[key] = value
                    }
                }
            }
        }
        dictionary.unionInPlace(dictionary: attributesDict)
        return dictionary
    }    
}



