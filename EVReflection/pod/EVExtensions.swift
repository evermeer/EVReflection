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

 - returns: True if the objects are the same, otherwise false.
*/
public func == (lhs: EVObject, rhs: EVObject) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

/**
Implementation for Equatable !=

- parameter lhs: The object at the left side of the ==
- parameter rhs: The object at the right side of the ==

 - returns: False if the objects are the the same, otherwise true.
*/
public func != (lhs: EVObject, rhs: EVObject) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}


/**
Extending Array with an initializer with a json string
*/
public extension Array where Element: NSObject {
    
    /**
    Initialize an array based on a json string
    
    - parameter json: The json string
    - parameter conversionOptions: Option set for the various conversion options.
    */
    public init(json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.arrayFromJson(nil, type:arrayTypeInstance, json: json, conversionOptions: conversionOptions)
        for item in newArray {
            self.append(item)
        }
    }

    /**
     Initialize an array based on a dictionary
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(dictionaryArray: [NSDictionary], conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        for item in dictionaryArray {
            let arrayTypeInstance = getArrayTypeInstance(self)
            if arrayTypeInstance is EVObject {
                EVReflection.setPropertiesfromDictionary(item, anyObject: arrayTypeInstance as! EVObject)
                self.append(arrayTypeInstance)
            }
        }
    }
    
    /**
    Get the type of the object where this array is for
    
    - parameter arr: this array
    
    - returns: The object type
    */
    public func getArrayTypeInstance<T: NSObject>(arr: Array<T>) -> T {
        return arr.getTypeInstance()
    }
    
    /**
    Get the type of the object where this array is for
    
    - returns: The object type
    */
    public func getTypeInstance<T: NSObject>(
        ) -> T {
        if let nsobjectype: NSObject.Type = T.self {
            let nsobject: NSObject = nsobjectype.init()
            if let obj =  nsobject as? T {
                return obj
            }
            // Could not instantiate array item instance. will crash
            return (nsobject as? T)!
        }
        // Could not instantiate array item instance. will crash
        assert(false, "You can only instantiate an array of objects that have EVObject (or NSObject) as its base class. Please make this change to your object: \(T.self)")

        return (NSObject() as? T)!
    }
    
    /**
    Convert this array to a json string
    
    - parameter conversionOptions: Option set for the various conversion options.
    
    - returns: The json string
    */
    public func toJsonString(conversionOptions: ConversionOptions = .DefaultSerialize) -> String {
        return "[\n" + self.map({($0 as? EVObject ?? EVObject()).toJsonString(conversionOptions)}).joinWithSeparator(", \n") + "\n]"
    }
    
    /**
     Returns the dictionary representation of this array.
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The array of dictionaries
     */
    public func toDictionaryArray(conversionOptions: ConversionOptions = .DefaultSerialize) -> NSArray {
        return self.map({($0 as? EVObject ?? EVObject()).toDictionary(conversionOptions)})
    }
}
