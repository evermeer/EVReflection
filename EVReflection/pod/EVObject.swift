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
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder, conversionOptions: .DefaultNSCoding)
    }
    
    /**
    Convenience init for creating an object whith the property values of a dictionary.
    
    - parameter dictionary: The dictionary that will be used to create this object
    - parameter conversionOptions: Option set for the various conversion options.
    */
    public convenience init(dictionary: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self, conversionOptions: conversionOptions)
    }
    
    /**
    Convenience init for creating an object whith the contents of a json string.
    
    - parameter json: The json string that will be used to create this object
    - parameter conversionOptions: Option set for the various conversion options.
    */
    public convenience init(json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self, conversionOptions: conversionOptions)
    }
    
    /**
    Encode this object using a NSCoder
    
    - parameter aCoder: The NSCoder that will be used for encoding the object
    */
    public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder, conversionOptions: .DefaultNSCoding)
    }        
    
    /**
    Initialize this object from an archived file from the temp directory
    
    - parameter fileNameInTemp: The filename
    - parameter conversionOptions: Option set for the various conversion options.
    */
    public convenience init(fileNameInTemp: String, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        self.init()
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileNameInTemp)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(conversionOptions), anyObject: self, conversionOptions: conversionOptions)
        }
    }
    
    /**
    Initialize this object from an archived file from the documents directory
    
    - parameter fileNameInDocuments: The filename
    - parameter conversionOptions: Option set for the various conversion options.
    */
    public convenience init(fileNameInDocuments: String, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        self.init()
        let filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent(fileNameInDocuments)
        if let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EVObject {
            EVReflection.setPropertiesfromDictionary( temp.toDictionary(conversionOptions), anyObject: self, conversionOptions: conversionOptions)
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
            self.addStatusMessage(.InvalidClass, message: "class should have implemented the setValue forUndefinedKey.")
            print("\nWARNING: Your class should have implemented the setValue forUndefinedKey. \n")
        } else {
            self.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            print("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
    
        }
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
    
    - parameter conversionOptions: Option set for the various conversion options.
    
    - returns: The dictionary
    */
    public func toDictionary(conversionOptions: ConversionOptions = .DefaultSerialize) -> NSDictionary {
        let (reflected, _) = EVReflection.toDictionary(self, conversionOptions: conversionOptions)
        return reflected
    }
    
    /**
     Convert this object to a json string
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The json string
     */
    public func toJsonString(conversionOptions: ConversionOptions = .DefaultSerialize) -> String {
        return EVReflection.toJsonString(self, conversionOptions: conversionOptions)
    }
    
    /**
     Convenience method for instantiating an array from a json string.
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: An array of objects
     */
    public class func arrayFromJson<T where T:NSObject>(json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> [T] {
        return EVReflection.arrayFromJson(nil, type: T(), json: json, conversionOptions: conversionOptions)
    }
    
    /**
     Auto map an opbject to an object of an other type.
     Properties with the same name will be mapped automattically.
     Automattic cammpelCase, PascalCase, snake_case conversion
     Supports propperty mapping and conversion when using EVObject as base class
     
     - parameter conversionOptions: Option set for the various conversion options.

     - returns: The targe object with the mapped values
     */
    public func mapObjectTo<T where T:NSObject>(conversionOptions: ConversionOptions = .DefaultDeserialize) -> T {
        let nsobjectype: NSObject.Type = T.self as NSObject.Type
        let nsobject: NSObject = nsobjectype.init()
        let dict = self.toDictionary()
        let result = EVReflection.setPropertiesfromDictionary(dict, anyObject: nsobject, conversionOptions: conversionOptions)
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
    
    /**
     get the type of a property
     
     - parameter propertyName: The property key
     - parameter mirror:       The mirror of this object
     
     - returns: The type of the property
     */
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
    
    /**
     By default there is no aditional validation. Override this function to add your own class level validation rules
     
     - parameter dict: The dictionary with keys where the initialisation is called with
     */
    public func initValidation(dict: NSDictionary) {
    }
    
    /**
     Validation function that you will probably call from the initValidation function. This function will make sure
     the passed on keys are not in the dictionary used for initialisation. 
     The result of this validation is stored in evReflectionStatus.
     
     - parameter keys: The fields that may not be in the dictionary (like an error key)
     - parameter dict: The dictionary that is passed on from the initValidation function
     */
    public func initMayNotContainKeys(keys: [String], dict: NSDictionary) {
        for key in keys {
            if dict[key] != nil {
                addStatusMessage(.IncorrectKey, message: "Invalid key: \(key)")
            }
        }
    }
    
    /**
     Validation function that you will probably call from the initValidation function. This function will make sure
     the passed on keys are in the dictionary used for initialisation.
     The result of this validation is stored in evReflectionStatus.
     
     - parameter keys: The fields that may not be in the dictionary (like an error key)
     - parameter dict: The dictionary that is passed on from the initValidation function
     */
    public func initMustContainKeys(keys: [String], dict: NSDictionary) {
        for key in keys {
            if dict[key] == nil {
                addStatusMessage(.MissingKey, message: "Missing key: \(key)")
            }
        }
    }
    
    /// This property will contain an array with deserialisation statussses with a description
    public var evReflectionStatuses: [(DeserialisationStatus, String)] = []
    /**
     Return a merged status out of the status array
     
     - returns: the deserialisation status for the object
     */
    public func evReflectionStatus() -> DeserialisationStatus {
        var status: DeserialisationStatus = .None
        for (s, _) in evReflectionStatuses {
            status = [status, s]
        }
        return status
    }
    /**
     Convenience function for adding a new status message to the evReflectionStatus array
     
     - parameter type:    A string to specify the message type
     - parameter message: The message for the status.
     */
    public func addStatusMessage(type: DeserialisationStatus, message: String) {
        evReflectionStatuses.append(type, message)
    }
    
    /**
     Convert a Swift dictionary to a NSDictionary.
     
     - parameter key:  Key of the property that is the dictionary. Can be used when overriding this function
     - parameter dict: The Swift dictionary
     
     - returns: The dictionary converted to a NSDictionary
     */
    public func convertDictionary(key: String, dict: Any) -> NSDictionary {        
        let returnDict = NSMutableDictionary()
        for (key, value) in dict as? NSDictionary ?? NSDictionary() {
            returnDict[key as? String ?? ""] = value
        }
        return returnDict
    }
    
}
