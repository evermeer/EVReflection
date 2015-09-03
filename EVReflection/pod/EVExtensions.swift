//
//  EVExtensions.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2015 evict. All rights reserved.
//

import Foundation

/**
Implementation for Equatable ==

- parameter lhs: The object at the left side of the ==
- parameter rhs: The object at the right side of the ==
:return: True if the objects are the same, otherwise false.
*/
public func ==(lhs: NSObject, rhs: NSObject) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

/**
Implementation for Equatable !=

- parameter lhs: The object at the left side of the ==
- parameter rhs: The object at the right side of the ==
:return: False if the objects are the the same, otherwise true.
*/
public func !=(lhs: NSObject, rhs: NSObject) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}


public extension NSObject {
    /**
    Convenience init for creating an object whith the property values of a dictionary.
    */
    public convenience init(dictionary:NSDictionary) {
        self.init()
        EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self)
    }
    
    /**
    Convenience init for creating an object whith the contents of a json string.
    */
    public convenience init(json:String?) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
    }
    
    /**
    Returns the dictionary representation of this object.
    */
    final public func toDictionary() -> NSDictionary {
        let (reflected, _) = EVReflection.toDictionary(self)
        return reflected
    }
    
    final public func toJsonString() -> String {
        return EVReflection.toJsonString(self)
    }
    
    /**
    Convenience method for instantiating an array from a json string.
    */
    public class func arrayFromJson<T where T:EVObject>(json:String?) -> [T] {
        return EVReflection.arrayFromJson(T(), json: json)
    }
    
    /**
    Returns the pritty description of this object
    
    :return: The pritty description
    */
    public var description: String {
        get {
            return EVReflection.description(self)
        }
    }

    /**
    Returns the pritty description of this object
    
    :return: The pritty description
    */
    public var debugDescription: String {
        get {
            return EVReflection.description(self)
        }
    }

    /**
    Returns the hashvalue of this object
    
    :return: The hashvalue of this object
    */
    public var hashValue: Int {
        get {
            return EVReflection.hashValue(self)
        }
    }
    
    /**
    Function for returning the hash for the NSObject based functionality
    
    :return: The hashvalue of this object
    */
    public var hash: Int {
        get {
            return self.hashValue
        }
    }
}


/**
Extending Array with an initializer with a json string
*/
extension Array {
    init(json:String){
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.arrayFromJson(arrayTypeInstance, json: json)
        for item in newArray {
            self.append(item)
        }
    }
    
    private func getArrayTypeInstance<T>(arr:Array<T>) -> T {
        return arr.getTypeInstance()
    }
    
    private func getTypeInstance<T>(
        ) -> T {
            let nsobjectype : NSObject.Type = T.self as! NSObject.Type
            let nsobject: NSObject = nsobjectype.init()
            return nsobject as! T
    }
}
