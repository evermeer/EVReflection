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
public class EVObject: NSObject, NSCoding { // These are redundant in Swift 2+: CustomDebugStringConvertible, CustomStringConvertible, Hashable, Equatable
    
    /**
    This basic init override is needed so we can use EVObject as a base class.
    */
    public required override init(){
        super.init()
    }
    
    /**
    Decode any object
    
    This method is in EVObject and not in NSObject because you would get the error: Initializer requirement 'init(coder:)' can only be satisfied by a `required` initializer in the definition of non-final class 'NSObject'
    
    :parameter: theObject The object that we want to decode.
    :parameter: aDecoder The NSCoder that will be used for decoding the object.
    */
    public convenience required init?(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder)
    }
    
    /**
    Convenience init for creating an object whith the property values of a dictionary.
    
    :parameter: dictionary The dictionary that will be used to create this object
    */
    public convenience init(dictionary:NSDictionary) {
        self.init()
        EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self)
    }
    
    /**
    Convenience init for creating an object whith the contents of a json string.
    
    :json: The json string that will be used to create this object
    */
    public convenience init(json:String?) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
    }
    
    /**
    Encode this object using a NSCoder
    
    :parameter: aCoder The NSCoder that will be used for encoding the object
    */
    public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder)
    }        
    
    /**
    Initialize this object from an archived file from the temp directory
    
    :parameter: fileName The filename
    */
    public convenience init(fileNameInTemp:String) {
        self.init()
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileNameInTemp)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(false), anyObject: self)
        }
    }
    
    /**
    Initialize this object from an archived file from the documents directory
    
    :parameter: fileName The filename
    */
    public convenience init(fileNameInDocuments:String) {
        self.init()
        let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent(fileNameInDocuments)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(false), anyObject: self)
        }
    }
    

    /**
    Returns the pritty description of this object
    
    :returns: The pritty description
    */
    public override var description: String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the pritty description of this object
    
    :returns: The pritty description
    */
    public override var debugDescription: String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the hashvalue of this object
    
    :returns: The hashvalue of this object
    */
    public override var hashValue: Int {
        get {
            return Int(EVReflection.hashValue(self))
        }
    }
    
    /**
    Function for returning the hash for the NSObject based functionality
    
    :returns: The hashvalue of this object
    */
    public override var hash: Int {
        get {
            return self.hashValue
        }
    }
    
    /**
    Save this object to a file in the temp directory
    
    :parameter: fileName The filename
    
    :returns: Nothing
    */
    public func saveToTemp(fileName:String) -> Bool {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileName)
        return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }

    

    #if os(tvOS)
        // Save to documents folder is not supported on tvOS
    #else
        /**
        Save this object to a file in the documents directory
        
        :parameter: fileName The filename
        
        :returns: Nothing
        */
        public func saveToDocuments(fileName:String) -> Bool {
            let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent(fileName)
            return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
        }
    #endif
    
    
    
    
    /**
    Implementation of the NSObject isEqual comparisson method

    This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector

    :parameter: object The object where you want to compare with

    :returns: Returns true if the object is the same otherwise false
    */
    public override func isEqual(object: AnyObject?) -> Bool { // for isEqual:
        if let dataObject = object as? EVObject {
            return dataObject == self // just use our "==" function
        }
        return false
    }

    
    /**
    Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
    
    This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
    
    :parameter: value The value that you wanted to set
    :parameter: key The name of the property that you wanted to set

    :returns: Nothing
    */
    public override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        if let _ = self as? EVGenericsKVC {
            NSLog("\nWARNING: Your class should have implemented the setValue forUndefinedKey. \n")
        }
        NSLog("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
    }

    
    /**
    Override this method when you want custom property mapping.
    
    This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
    
    :returns: Return an array with value pairs of the object property name and json key name.
    */
    public func propertyMapping() -> [(String?, String?)] {
        return []
    }
    
    /**
    Override this method when you want custom property value conversion
    
    This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
    
    :returns: Returns an array where each item is a combination of the folowing 3 values: A string for the property name where the custom conversion is for, a setter function and a getter function.
    */
    public func propertyConverters() -> [(String?, ((Any?)->())?, (() -> Any?)? )] {
        return []
    }

    /**
     When a property is declared as a base type for multiple enherited classes, then this function will let you pick the right specific type based on the suplied dictionary.
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    public func getSpecificType(dict: NSDictionary) -> EVObject {
        return self
    }
    
    
    
    // MARK: - The code below was originally in a NSObject extension.
    
    
    /**
    Returns the dictionary representation of this object.
    
    :parameter: performKeyCleanup set to true if you want to cleanup the keys
    
    :returns: The dictionary
    */
    final public func toDictionary(performKeyCleanup:Bool = false) -> NSDictionary {
        let (reflected, _) = EVReflection.toDictionary(self, performKeyCleanup: performKeyCleanup)
        return reflected
    }
    
    /**
     Convert this object to a json string
     
     :parameter: performKeyCleanup set to true if you want to cleanup the keys
     
     :returns: The json string
     */
    final public func toJsonString(performKeyCleanup:Bool = false) -> String {
        return EVReflection.toJsonString(self, performKeyCleanup: performKeyCleanup)
    }
    
    /**
     Convenience method for instantiating an array from a json string.
     
     :parameter: json The json string
     
     :returns: An array of objects
     */
    public class func arrayFromJson<T where T:NSObject>(json:String?) -> [T] {
        return EVReflection.arrayFromJson(T(), json: json)
    }
    
    /**
     Auto map an opbject to an object of an other type.
     Properties with the same name will be mapped automattically.
     Automattic cammpelCase, PascalCase, snake_case conversion
     Supports propperty mapping and conversion when using EVObject as base class
     
     - returns: The targe object with the mapped values
     */
    public func mapObjectTo<T where T:NSObject>() -> T {
        let nsobjectype : NSObject.Type = T.self as NSObject.Type
        let nsobject: NSObject = nsobjectype.init()
        let dict = self.toDictionary()
        let result = EVReflection.setPropertiesfromDictionary(dict, anyObject: nsobject)
        return result as! T
    }
    
}









