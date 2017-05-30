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
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue197() {
        
        EVReflection.setBundleIdentifier(Base.self)
        
        let jsonOriginal = "{\"id\":24,\"name\":\"Bob Jefferson\",\"details\":[{\"id\": 29,\"name\":\"Jen Jackson\"}]}"
        let p = Master(json: jsonOriginal)
        p.details.forEach { print($0.description) }
        
        
        let jsonNew = p.toJsonString()
        print("--- Original ----")
        print(jsonOriginal)
        print("  ")
        print("--- New with Details with Attributes ----")
        print(jsonNew)
        print("  ")
        XCTAssertEqual(jsonOriginal, jsonNew, "The new json should be the same as the old.")
        
    }
    /* results
     --- Original ----
     {"id": 24, "name": "Bob Jefferson", "details": [{"id": 29, "name": "Jen Jackson"}]}
     
     --- Master is ok but  Details contains Attributes ----
     {"id":24,"details":[{"attributes":{},"id":29,"name":"Jen Jackson"}],"name":"Bob Jefferson"}
     
     
     */

    public struct CogDirect {
        public struct Modules {
        }
        public struct Model {
    
            class Model : EVObject {
                // this part is just to circumvent having to use enums
                public static let STATUS : [NSString] = [
                    "success",
                    "failed",
                    "unset"
                ]
                
                public static let STATUS_SUCCESS : Int = 0
                public static let STATUS_FAILED = 1
                public static let STATUS_UNSET = 2
                // end
                
                public var status : NSString = STATUS[STATUS_UNSET]
                public var subject : NSString = "unset"
                public var message : NSString = ""
            }
            
            
            class BeaconModel : EVObject {
                public var uuid : NSString = ""
                public var major : Int = -1
                public var minor : Int = -1
                public var accuracy : Double = -1
            }
            
            class BeaconsModel : Model {
                public var beacons : [BeaconModel] = [] // this part is not key-value coding compliant
            }
        }
    }

    
    func testXXX() {        
        let x = CogDirect.Model.BeaconsModel()
        x.beacons.append(CogDirect.Model.BeaconModel())
        let json = x.toJsonString()
        print(json)
        let nx = CogDirect.Model.BeaconsModel(json: json)
        print(nx)
    }
    
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
    public func constructWith(value: Any?) {
        if let jsonDict = value as? NSDictionary {
            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
        }
    }
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - returns: Dictionary without custom properties key
     */
    public func toCodableValue() -> Any {
        let originalDict: NSMutableDictionary = self.toDictionary() as! NSMutableDictionary
        
        let attributesDict: NSMutableDictionary = originalDict[Base197.kAttributesKey] as? NSMutableDictionary ?? NSMutableDictionary()
        originalDict.removeObject(forKey: Base197.kAttributesKey)
        
        //---> Workaround because toCodableValue is not invoked for the details
        originalDict.forEach {
            if let key = $0.key as? String {
                if let value = $0.value as? NSArray {
                    originalDict[key] = toCodableValueArray(value)
                }
            }
        }
        //---------------------------
        
        originalDict.unionInPlace(dictionary: attributesDict)
        return originalDict
    }
    
    /**
     Create a json string based on this dictionary
     
     - returns: json string
     */
    public func toJsonString(prettyPrinted: Bool = false) -> String {
        let dict = self.toCodableValue() as? NSMutableDictionary
        return dict?.toJsonString(prettyPrinted: prettyPrinted) ?? ""
    }
    
    
    /**
     Create a json data based on this dictionary
     
     - parameter prettyPrinted: compact of pretty printed
     */
    public func toJsonData(prettyPrinted: Bool = false) -> Data {
        let dict = self.toCodableValue() as? NSMutableDictionary
        let data = dict?.toJsonData(prettyPrinted: prettyPrinted)
        return data ?? Data()
    }
    
    /**
     Converts value if array contains Base elements
     
     - returns: Array contains all Base
     */
    
    private func toCodableValueArray(_ value: NSArray) -> NSArray {
        
        let array: NSMutableArray = NSMutableArray()
        value.forEach {
            
            //----> Here $0 is NSObject but must be Base !!?????
            if let object = $0 as? Base197 {
                let objectDict = object.toCodableValue() as? NSMutableDictionary
                if let elementDict = objectDict {
                    array.add(elementDict)
                }
            } else {
                array.add($0)
            }
            
        }
        
        return array
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


