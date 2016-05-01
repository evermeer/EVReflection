//
//  EVObject.swift
//
//  Created by Edwin Vermeer on 5/2/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

/**
 Object that will support NSCoding, Printable, Hashable and Equeatable for all properties. Use this object as your base class
 instead of NSObject and you wil automatically have support for all these protocols.
*/
public class EVObject: NSObject, NSCoding { // These are redundant in Swift 2+: CustomDebugStringConvertible, CustomStringConvertible, Hashable, Equatable
    
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
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder, convertionOptions: .None)
    }
    
    /**
    Convenience init for creating an object whith the property values of a dictionary.
    
    - parameter dictionary: The dictionary that will be used to create this object
    - parameter convertionOptions: Option set for the various conversion options.
    */
    public convenience init(dictionary: NSDictionary, convertionOptions: ConvertionOptions = .Default) {
        self.init()
        EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self, convertionOptions: convertionOptions)
    }
    
    /**
    Convenience init for creating an object whith the contents of a json string.
    
    - parameter json: The json string that will be used to create this object
    - parameter convertionOptions: Option set for the various conversion options.
    */
    public convenience init(json: String?, convertionOptions: ConvertionOptions = .Default) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self, convertionOptions: convertionOptions)
    }
    
    /**
    Encode this object using a NSCoder
    
    - parameter aCoder: The NSCoder that will be used for encoding the object
    */
    public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder, convertionOptions: .None)
    }        
    
    /**
    Initialize this object from an archived file from the temp directory
    
    - parameter fileNameInTemp: The filename
    - parameter convertionOptions: Option set for the various conversion options.
    */
    public convenience init(fileNameInTemp: String, convertionOptions: ConvertionOptions = .None) {
        self.init()
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileNameInTemp)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(convertionOptions), anyObject: self, convertionOptions: convertionOptions)
        }
    }
    
    /**
    Initialize this object from an archived file from the documents directory
    
    - parameter fileNameInDocuments: The filename
    - parameter convertionOptions: Option set for the various conversion options.
    */
    public convenience init(fileNameInDocuments: String, convertionOptions: ConvertionOptions = .None) {
        self.init()
        let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent(fileNameInDocuments)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(convertionOptions), anyObject: self, convertionOptions: convertionOptions)
        }
    }
    

    /**
    Returns the pritty description of this object
    
    - returns: The pritty description
    */
    public override var description: String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the pritty description of this object
    
    - returns: The pritty description
    */
    public override var debugDescription: String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the hashvalue of this object
    
    - returns: The hashvalue of this object
    */
    public override var hashValue: Int {
        get {
            return Int(EVReflection.hashValue(self))
        }
    }
    
    /**
    Function for returning the hash for the NSObject based functionality
    
    - returns: The hashvalue of this object
    */
    public override var hash: Int {
        get {
            return self.hashValue
        }
    }
    
    /**
    Save this object to a file in the temp directory
    
    - parameter fileName: The filename
    
    - returns: Nothing
    */
    public func saveToTemp(fileName: String) -> Bool {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileName)
        return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }

    

    #if os(tvOS)
        // Save to documents folder is not supported on tvOS
    #else
        /**
        Save this object to a file in the documents directory
        
        - parameter fileName: The filename
     
        - returns: true if successfull
        */
        public func saveToDocuments(fileName: String) -> Bool {
            let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent(fileName)
            return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
        }
    #endif
    
    
    
    
    /**
    Implementation of the NSObject isEqual comparisson method

    This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector

    - parameter object: The object where you want to compare with

    - returns: Returns true if the object is the same otherwise false
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
    
    - parameter value: The value that you wanted to set
    - parameter key: The name of the property that you wanted to set
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
    
    - returns: Return an array with value pairs of the object property name and json key name.
    */
    public func propertyMapping() -> [(String?, String?)] {
        return []
    }
    
    /**
    Override this method when you want custom property value conversion
    
    This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
    
    - returns: Returns an array where each item is a combination of the folowing 3 values: A string for the property name where the custom conversion is for, a setter function and a getter function.
    */
    public func propertyConverters() -> [(String?, ((Any?)->())?, (() -> Any?)? )] {
        return []
    }

    /**
     This is a general functon where you can filter for specific values (like nil or empty string) when creating a dictionary
     
     - parameter value:  The value that we will test
     - parameter key: The key for the value 
     
     - returns: True if the value needs to be ignored.
     */
    public func skipPropertyValue(value: Any, key: String) -> Bool {
        return false
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
    
    - parameter convertionOptions: Option set for the various conversion options.
    
    - returns: The dictionary
    */
    public func toDictionary(convertionOptions: ConvertionOptions = .Default) -> NSDictionary {
        let (reflected, _) = EVReflection.toDictionary(self, convertionOptions: convertionOptions)
        return reflected
    }
    
    /**
     Convert this object to a json string
     
     - parameter convertionOptions: Option set for the various conversion options.
     
     - returns: The json string
     */
    public func toJsonString(convertionOptions: ConvertionOptions = .Default) -> String {
        return EVReflection.toJsonString(self, convertionOptions: convertionOptions)
    }
    
    /**
     Convenience method for instantiating an array from a json string.
     
     - parameter json: The json string
     - parameter convertionOptions: Option set for the various conversion options.
     
     - returns: An array of objects
     */
    public class func arrayFromJson<T where T:NSObject>(json: String?, convertionOptions: ConvertionOptions = .Default) -> [T] {
        return EVReflection.arrayFromJson(T(), json: json, convertionOptions: convertionOptions)
    }
    
    /**
     Auto map an opbject to an object of an other type.
     Properties with the same name will be mapped automattically.
     Automattic cammpelCase, PascalCase, snake_case conversion
     Supports propperty mapping and conversion when using EVObject as base class
     
     - parameter convertionOptions: Option set for the various conversion options.

     - returns: The targe object with the mapped values
     */
    public func mapObjectTo<T where T:NSObject>(convertionOptions: ConvertionOptions = .Default) -> T {
        let nsobjectype: NSObject.Type = T.self as NSObject.Type
        let nsobject: NSObject = nsobjectype.init()
        let dict = self.toDictionary()
        let result = EVReflection.setPropertiesfromDictionary(dict, anyObject: nsobject, convertionOptions: convertionOptions)
        return result as? T ?? T()
    }
    
    /**
     Get the type for a given property name or `nil` if there aren't any properties matching said name.
     
     - parameter propertyName: The property name
     
     - returns: The type for the property
     */
    public func typeForKey(propertyName: String) -> Any.Type? {
        let mirror = Mirror(reflecting: self)
        return typeForKey(propertyName, mirror: mirror)
    }
    
    private func typeForKey(propertyName: String, mirror: Mirror) -> Any.Type? {
        for (label, value) in mirror.children {
            if propertyName == label {
                return Mirror(reflecting: value).subjectType
            }
        }
        
        guard let superclassMirror = mirror.superclassMirror() else {
            return nil
        }
        
        return typeForKey(propertyName, mirror: superclassMirror)
    }
}
