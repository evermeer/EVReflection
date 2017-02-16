//
//  EVObject.swift
//
//  Created by Edwin Vermeer on 5/2/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation


/**
 Object that implements EVReflectable and NSCoding. Use this object as your base class
 instead of NSObject and you wil automatically have support for all these protocols.
 */
open class EVObject: NSObject, NSCoding, EVReflectable  {
    // These are redundant in Swift 2+: CustomDebugStringConvertible, CustomStringConvertible, Hashable, Equatable
    
    /**
     Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter value: The value that you wanted to set
     - parameter key: The name of the property that you wanted to set
     */
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let kvc = self as? EVGenericsKVC {
            kvc.setGenericValue(value as AnyObject!, forUndefinedKey: key)
        } else {
            self.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            print("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
            
        }
    }
    
    /**
     Implementation of the NSObject isEqual comparisson method
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter object: The object where you want to compare with
     
     - returns: Returns true if the object is the same otherwise false
     */

    open override func isEqual(_ object: Any?) -> Bool { // for isEqual:
        if let obj = object as? EVObject {
            return EVReflection.areEqual(self, rhs: obj)
        }
        return false
    }

    /**
     Returns the pritty description of this object
     
     - returns: The pritty description
     */
    open override var description: String {
        get {
            return EVReflection.description(self, prettyPrinted: true)
        }
    }
    
    /**
     Returns the pritty description of this object
     
     - returns: The pritty description
     */
    open override var debugDescription: String {
        get {
            return EVReflection.description(self, prettyPrinted: true)
        }
    }
    
    /**
     This basic init override is needed so we can use EVObject as a base class.
     */
    public required override init() {
        super.init()
    }

    /**
     Decode any object
     
     This method is in EVObject and not in NSObject because you would get the error: Initializer requirement 'init(coder:)' can
     only be satisfied by a `required` initializer in the definition of non-final class 'NSObject'
     
     -parameter coder: The NSCoder that will be used for decoding the object.
     */
    public convenience required init?(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder, conversionOptions: .DefaultNSCoding)
    }
    
    
    /**
     Encode this object using a NSCoder
     
     - parameter aCoder: The NSCoder that will be used for encoding the object
     */
    open func encode(with aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self , aCoder: aCoder, conversionOptions: .DefaultNSCoding)
    }

    
    //MARK - Default implementation of protocol functions that we can override
    
    
    /**
     By default there is no aditional validation. Override this function to add your own class level validation rules
     
     - parameter dict: The dictionary with keys where the initialisation is called with
     */
    open func initValidation(_ dict: NSDictionary) {
    }
    
    /**
     Override this method when you want custom property mapping.
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Return an array with value pairs of the object property name and json key name.
     */
    open func propertyMapping() -> [(String?, String?)] {
        return []
    }
    
    /**
     Override this method when you want custom property value conversion
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Returns an array where each item is a combination of the folowing 3 values: A string for the property name where the custom conversion is for, a setter function and a getter function.
     */
    open func propertyConverters() -> [(key: String, decodeConverter: ((Any?)->()), encodeConverter: (() -> Any?))] {
        return []
    }
    
    /**
     This is a general functon where you can filter for specific values (like nil or empty string) when creating a dictionary
     
     - parameter value:  The value that we will test
     - parameter key: The key for the value
     
     - returns: True if the value needs to be ignored.
     */
    open func skipPropertyValue(_ value: Any, key: String) -> Bool {
        return false
    }
        
    /**
     When a property is declared as a base type for multiple inherited classes, then this function will let you pick the right specific type based on the suplied dictionary.
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    open func getSpecificType(_ dict: NSDictionary) -> EVReflectable? {
        return nil
    }
}



