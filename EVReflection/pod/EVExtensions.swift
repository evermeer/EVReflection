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
:returns: True if the objects are the same, otherwise false.
*/
public func ==(lhs: EVObject, rhs: EVObject) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

/**
Implementation for Equatable !=

- parameter lhs: The object at the left side of the ==
- parameter rhs: The object at the right side of the ==
:returns: False if the objects are the the same, otherwise true.
*/
public func !=(lhs: EVObject, rhs: EVObject) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}


/**
Extending Array with an initializer with a json string
*/
public extension Array {
    
    /**
    Initialize an array based on a json string
    
    :parameter: json The json string
    
    :returns: The array of objects
    */
    public init(json:String?){
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.arrayFromJson(arrayTypeInstance, json: json)
        for item in newArray {
            self.append(item)
        }
    }
    
    /**
    Get the type of the object where this array is for
    
    :parameter: arr this array
    
    :returns: The object type
    */
    public func getArrayTypeInstance<T>(arr:Array<T>) -> T {
        return arr.getTypeInstance()
    }
    
    /**
    Get the type of the object where this array is for
    
    :returns: The object type
    */
    public func getTypeInstance<T>(
        ) -> T {
            let nsobjectype : NSObject.Type = T.self as! NSObject.Type
            let nsobject: NSObject = nsobjectype.init()
            return nsobject as! T
    }
    
    /**
    Convert this array to a json string
    
    :parameter: performKeyCleanup set to true if you want to cleanup the keys
    
    :returns: The json string
    */
    public func toJsonString(performKeyCleanup:Bool = false) -> String {
        return "[\n" + self.map({($0 as! EVObject).toJsonString(performKeyCleanup)}).joinWithSeparator(", \n") + "\n]"
    }
    
    /**
     Returns the dictionary representation of this array.
     
     :parameter: performKeyCleanup set to true if you want to cleanup the keys
     
     :returns: The array of dictionaries
     */
    public func toDictionaryArray(performKeyCleanup:Bool = false) -> NSArray {
        return self.map({($0 as! EVObject).toDictionary(performKeyCleanup)})
    }
    
}
