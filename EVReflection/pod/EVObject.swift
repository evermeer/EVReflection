//
//  EVObject.swift
//
//  Created by Edwin Vermeer on 5/2/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

/**
Object that will support NSCoding, Printable, Hashable and Equeatable for all properties. Use this object as your base class instead of NSObject and you wil automatically have support for all these protocols.
*/
public class EVObject: NSObject, NSCoding, CustomDebugStringConvertible { // These are redundant in Swift 2: CustomStringConvertible, Hashable, Equatable
    
    /**
    Basic init override is needed so we can use EVObject as a base class.
    */
    public required override init(){
        super.init()
    }
    
    /**
    Decode any object
    
    - In EVObject and not in NSObject because: Initializer requirement 'init(coder:)' can only be satisfied by a `required` initializer in the definition of non-final class 'NSObject'
    
    - parameter theObject: The object that we want to decode.
    - parameter aDecoder: The NSCoder that will be used for decoding the object.
    */
    public convenience required init?(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder)
    }
    
    /**
    Encode this object using a NSCoder
    
    - parameter aCoder: The NSCoder that will be used for encoding the object
    */
    public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder)
    }        
    
    /**
    Implementation of the NSObject isEqual comparisson method

    - In EVObject and not in NSObject extension because: method conflicts with previous declaration with the same Objective-C selector

    - parameter object: The object where you want to compare with
    :return: Returns true if the object is the same otherwise false
    */
    public override func isEqual(object: AnyObject?) -> Bool { // for isEqual:
        if let dataObject = object as? EVObject {
            return dataObject == self // just use our "==" function
        } else { return false }
    }

    
    /**
    Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
    
    - In EVObject and not in NSObject extension because: method conflicts with previous declaration with the same Objective-C selector
    
    - parameter value: The value that you wanted to set
    - parameter key: The name of the property that you wanted to set
    */
    public override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        if let genericSelf = self as? EVGenericsKVC {
            genericSelf.setValue(value, forUndefinedKey: key)
            return
        }
        NSLog("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
    }

    
    /**
    Override this method when you want custom property mapping.
    
    - Is in EVObject and not in extension of NSObject because functions from extensions cannot be overwritten yet
    
    :return: Return an array with valupairs of the object property name and json key name.
    */
    public func propertyMapping() -> [(String?, String?)] {
        return []
    }
}



/**
Protocols created for easy workarounds
*/


/**
Protocol for the workaround when using generics. See WorkaroundSwiftGenericsTests.swift
*/
public protocol EVGenericsKVC {
    func setValue(value: AnyObject!, forUndefinedKey key: String)
}

/**
Protocol for the workaround when using an enum with a rawValue of type Int
*/
public protocol EVRawInt {
    var rawValue: Int { get }
}

/**
Protocol for the workaround when using an enum with a rawValue of type String
*/
public protocol EVRawString {
    var rawValue: String { get }
}

/**
Protocol for the workaround when using an enum with a rawValue of an undefined type
*/
public protocol EVRaw {
    var anyRawValue: Any { get }
}

/**
Protocol for the workaround when using an array with nullable values
*/
public protocol EVArrayConvertable {
    func convertArray(key: String, array: Any) -> NSArray
}








