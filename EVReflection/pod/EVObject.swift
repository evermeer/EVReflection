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
public class EVObject: NSObject, NSCoding, Printable, Hashable, Equatable {
    
    /**
    Basic init override is needed so we can use EVObject as a base class.
    */
    public override init(){
        super.init()
    }
    
    /**
    Decode any object
    
    :param: theObject The object that we want to decode.
    :param: aDecoder The NSCoder that will be used for decoding the object.
    */
    public convenience required init(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder)
    }
    
    /**
    Convenience init for creating an object whith the property values of a dictionary.
    */
    public convenience required init(dictionary:NSDictionary) {
        self.init()
        EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self)
    }
    
    /**
    Convenience init for creating an object whith the contents of a json string.
    */
    public convenience required init(json:String?) {
        self.init()
        var jsonDict = EVReflection.dictionaryFromJson(json)
        EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
    }
    
    /**
    Returns the dictionary representation of this object.
    */
    final public func toDictionary() -> NSDictionary {
        let (reflected, types) = EVReflection.toDictionary(self)
        return reflected
    }
    
    final public func toJsonString() -> String {
        return EVReflection.toJsonString(self)
    }
    
    /**
    Encode this object using a NSCoder
    
    :param: aCoder The NSCoder that will be used for encoding the object
    */
    final public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder)
    }
    
    /**
    Returns the pritty description of this object
    
    :return: The pritty description
    */
    final public override var description: String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the hashvalue of this object
    
    :return: The hashvalue of this object
    */
    public override var hashValue: Int {
        get {
            return EVReflection.hashValue(self)
        }
    }
    
    /**
    Function for returning the hash for the NSObject based functionality
    
    :return: The hashvalue of this object
    */
    final public override var hash: Int {
        get {
            return self.hashValue
        }
    }
    
    /**
    Implementation of the NSObject isEqual comparisson method
    
    :param: object The object where you want to compare with
    :return: Returns true if the object is the same otherwise false
    */
    final public override func isEqual(object: AnyObject?) -> Bool { // for isEqual:
        if let dataObject = object as? EVObject {
            return dataObject == self // just use our "==" function
        } else { return false }
    }
    
    /**
    Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
    
    :param: value The value that you wanted to set
    :param: key The name of the property that you wanted to set
    */
    public override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        if let genericSelf = self as? EVGenericsKVC {
            genericSelf.setValue(value, forUndefinedKey: key)
            return
        }
        NSLog("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
    }
    
    public func propertyMapping() -> [(String?, String?)] {
        return []
    }
    
}

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
    var anyRawValue: AnyObject { get }
}

/**
Protocol for the workaround when using an array with nullable values
*/
public protocol EVArrayConvertable {
    func convertArray(key: String, array: Any) -> NSArray
}


/**
Implementation for Equatable ==

:param: lhs The object at the left side of the ==
:param: rhs The object at the right side of the ==
:return: True if the objects are the same, otherwise false.
*/
public func ==(lhs: EVObject, rhs: EVObject) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

/**
Implementation for Equatable !=

:param: lhs The object at the left side of the ==
:param: rhs The object at the right side of the ==
:return: False if the objects are the the same, otherwise true.
*/
public func !=(lhs: EVObject, rhs: EVObject) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}


