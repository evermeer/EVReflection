//
//  EVReflectable.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 27/10/2016.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation

// MARK: - Protocol with the overridable functions. All functionality is added to this in the extension below.
public protocol EVReflectable: class, NSObjectProtocol  {
    /**
     By default there is no aditional validation. Override this function to add your own class level validation rules
     
     - parameter dict: The dictionary with keys where the initialisation is called with
     */
    func initValidation(_ dict: NSDictionary)
    
    /**
     Override this method when you want custom property mapping.
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Return an array with value pairs of the object property name and json key name.
     */
    func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)]
    
    /**
     Override this method when you want custom property value conversion
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Returns an array where each item is a combination of the folowing 3 values: A string for the property name where the custom conversion is for, a setter function and a getter function.
     */
    func propertyConverters() -> [(key: String, decodeConverter: ((Any?)->()), encodeConverter: (() -> Any?))]
    
    /**
     This is a general functon where you can filter for specific values (like nil or empty string) when creating a dictionary
     
     - parameter value:  The value that we will test
     - parameter key: The key for the value
     
     - returns: True if the value needs to be ignored.
     */
    func skipPropertyValue(_ value: Any, key: String) -> Bool
    
    /**
     You can add general value decoding to an object when you implement this function. You can for instance use it to base64 decode, url decode, html decode, unicode, etc.
     
     - parameter value:  The value that we will be decoded
     - parameter key: The key for the value
     
     - returns: The decoded value
     */
    func decodePropertyValue(value: Any, key: String) -> Any?

    /**
     You can add general value encoding to an object when you implement this function. You can for instance use it to base64 encode, url encode, html encode, unicode, etc.
     
     - parameter value:  The value that we will be encoded
     - parameter key: The key for the value
     
     - returns: The encoded value.
     */
    func encodePropertyValue(value: Any, key: String) -> Any
    
    /**
     Get the type of this object.
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    func getType(_ dict: NSDictionary) -> EVReflectable
    
    /**
     When a property is declared as a base type for multiple inherited classes, then this function will let you pick the right specific type based on the suplied dictionary.
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    func getSpecificType(_ dict: NSDictionary) -> EVReflectable?
    
    /**
     Return a custom object for the object
     
     - returns: The custom object that will be parsed (single value, dictionary or array)
     */
    func customConverter() -> AnyObject?

/*
    /**
     Declaration for Equatable ==
     
     - parameter lhs: The object at the left side of the ==
     - parameter rhs: The object at the right side of the ==
     
     - returns: True if the objects are the same, otherwise false.
     */
    static func ==(lhs: EVReflectable, rhs: EVReflectable) -> Bool
    
    /**
     Delclaration for Equatable !=
     
     - parameter lhs: The object at the left side of the ==
     - parameter rhs: The object at the right side of the ==
     
     - returns: False if the objects are the the same, otherwise true.
     */
    static func !=(lhs: EVReflectable, rhs: EVReflectable) -> Bool
*/
    /**
     Protocol container property for the reflection statusses
     */
    var evReflectionStatuses: [(DeserializationStatus, String)] { get set }
}


// MARK: - extending EVReflectable with the initialisation functions (which need NSObject)

var EVReflectableStatusesObjectKey = "EVReflectableStatuses"
extension EVReflectable where Self: NSObject {
    /**
     Trick for storing a property in a protocol only
     */
    public var evReflectionStatuses: [(DeserializationStatus, String)] {
        get {
            var statuses: [(DeserializationStatus, String)]? = objc_getAssociatedObject(self, &EVReflectableStatusesObjectKey) as? [(DeserializationStatus, String)]
            if let statuses = statuses {
                return statuses
            } else {
                statuses = [(DeserializationStatus, String)]()
                objc_setAssociatedObject(self, &EVReflectableStatusesObjectKey, statuses, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return statuses!
            }
        }
        set {
            objc_setAssociatedObject(self, &EVReflectableStatusesObjectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    /**
     init for creating an object whith the property values of a dictionary.
     
     - parameter dictionary: The dictionary that will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(dictionary: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()
        if let v = self as? EVCustomReflectable {
            let _ = v.constructWith(value: dictionary)
        } else {
            EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
        }
    }
    
    /**
     init for creating an object whith the contents of a json string.
     
     - parameter json: The json string that will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()
        let dictionary = EVReflection.dictionaryFromJson(json)
        if let v = self as? EVCustomReflectable {
            let _ = v.constructWith(value: dictionary)
        } else {
            EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
        }
    }
    
    /**
     init for creating an object whith the property values of json Data.
     
     - parameter dictionary: The dictionary that will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(data: Data, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()
        let dictionary: NSDictionary = (((try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary))  ?? NSDictionary())!
        if let v = self as? EVCustomReflectable {
            let _ = v.constructWith(value: dictionary)
        } else {
            EVReflection.setPropertiesfromDictionary(dictionary, anyObject: self, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
        }
    }
    
    
    /**
     Initialize this object from an archived file from the temp directory
     
     - parameter fileNameInTemp: The filename
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(fileNameInTemp: String, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        self.init()
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileNameInTemp)
        if let temp = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? EVReflectable {
            if let v = self as? EVCustomReflectable {
                let dictionary = temp.toDictionary(conversionOptions)
                let _ = v.constructWith(value: dictionary)
            } else {
                EVReflection.setPropertiesfromDictionary( temp.toDictionary(conversionOptions), anyObject: self, conversionOptions: conversionOptions)
            }
        }
    }
    
    /**
     Initialize this object from an archived file from the documents directory
     
     - parameter fileNameInDocuments: The filename
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(fileNameInDocuments: String, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        self.init()
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileNameInDocuments)
        if let temp = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? EVReflectable {
            if let v = self as? EVCustomReflectable {
                let dictionary = temp.toDictionary(conversionOptions)
                let _ = v.constructWith(value: dictionary)
            } else {
                EVReflection.setPropertiesfromDictionary( temp.toDictionary(conversionOptions), anyObject: self, conversionOptions: conversionOptions)
            }
        }
    }
    
    /**
     init for creating an object whith the property values of an other object.
     
     - parameter usingValuesFrom: The object of whicht the values will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(usingValuesFrom: EVReflectable, conversionOptions: ConversionOptions = .None) {
        self.init()
        let dict = usingValuesFrom.toDictionary()
        if let v = self as? EVCustomReflectable {
            let _ = v.constructWith(value: dict)
        } else {
            EVReflection.setPropertiesfromDictionary(dict, anyObject: self, conversionOptions: conversionOptions)
        }
        
    }
    
    /**
     Returns the hashvalue of this object
     
     - returns: The hashvalue of this object
     */
    public var hashValue: Int {
        get {
            return Int(EVReflection.hashValue(self))
        }
    }
    
    /**
     Function for returning the hash for the NSObject based functionality
     
     - returns: The hashvalue of this object
     */
    public var hash: Int {
        get {
            return self.hashValue
        }
    }
    
}


// MARK: - extending EVReflectable with most of EVReflection functionality


extension EVReflectable {
    /**
     Implementation for Equatable ==
     
     - parameter lhs: The object at the left side of the ==
     - parameter rhs: The object at the right side of the ==
     
     - returns: True if the objects are the same, otherwise false.
     */
    static public func == (lhs: EVReflectable, rhs: EVReflectable) -> Bool {
        if let lhso = lhs as? NSObject, let rhso = rhs as? NSObject {
            return EVReflection.areEqual(lhso, rhs: rhso)
        }
        return lhs.isEqual(rhs)
    }
    
    /**
     Implementation for Equatable !=
     
     - parameter lhs: The object at the left side of the ==
     - parameter rhs: The object at the right side of the ==
     
     - returns: False if the objects are the the same, otherwise true.
     */
    static public func != (lhs: EVReflectable, rhs: EVReflectable) -> Bool {
        if let lhso = lhs as? NSObject, let rhso = rhs as? NSObject {
            return !EVReflection.areEqual(lhso, rhs: rhso)
        }
        return !lhs.isEqual(rhs)
    }
    
    // MARK: - extending the base implementation for the overridable functions
    
    
    /**
     By default there is no aditional validation. Override this function to add your own class level validation rules
     
     - parameter dict: The dictionary with keys where the initialisation is called with
     */
    public func initValidation(_ dict: NSDictionary) {
    }
    
    /**
     Override this method when you want custom property mapping.
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Return an array with value pairs of the object property name and json key name.
     */
    public func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return []
    }
    
    /**
     Override this method when you want custom property value conversion
     
     This method is in EVObject and not in extension of NSObject because a functions from extensions cannot be overwritten yet
     
     - returns: Returns an array where each item is a combination of the folowing 3 values: A string for the property name where the custom conversion is for, a setter function and a getter function.
     */
    public func propertyConverters() -> [(key: String, decodeConverter: ((Any?)->()), encodeConverter: (() -> Any?))] {
        return []
    }
    
    /**
     This is a general functon where you can filter for specific values (like nil or empty string) when creating a dictionary
     
     - parameter value:  The value that we will test
     - parameter key: The key for the value
     
     - returns: True if the value needs to be ignored.
     */
    public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        return false
    }
    
    /**
     You can add general value decoding to an object when you implement this function. You can for instance use it to base64 decode, url decode, html decode, unicode, etc.
     
     - parameter value:  The value that we will be decoded
     - parameter key: The key for the value
     
     - returns: The decoded value
     */
    public func decodePropertyValue(value: Any, key: String) -> Any? {
        return value
    }
    
    /**
     You can add general value encoding to an object when you implement this function. You can for instance use it to base64 encode, url encode, html encode, unicode, etc.
     
     - parameter value:  The value that we will be encoded
     - parameter key: The key for the value
     
     - returns: The encoded value.
     */
    public func encodePropertyValue(value: Any, key: String) -> Any {
        return value
    }
    
    /**
     Return a custom object for the object
     
     - returns: The custom object that will be parsed (single value, dictionary or array)
     */
    public func customConverter() -> AnyObject? {
        return nil
    }
    
    /**
     Get the type of this object
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    public func getType(_ dict: NSDictionary) -> EVReflectable {
        return self
    }
    
    /**
     When a property is declared as a base type for multiple inherited classes, then this function will let you pick the right specific type based on the suplied dictionary.
     
     - parameter dict: The dictionary for the specific type
     
     - returns: The specific type
     */
    public func getSpecificType(_ dict: NSDictionary) -> EVReflectable? {
        return nil
    }
    
    // MARK: - extension methods
    
    
    /**
     Save this object to a file in the temp directory
     
     - parameter fileName: The filename
     
     - returns: Nothing
     */
    @discardableResult
    public func saveToTemp(_ fileName: String) -> Bool {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
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
    @discardableResult
    public func saveToDocuments(_ fileName: String) -> Bool {
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
        return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
    #endif
    
    
    /**
     Returns the dictionary representation of this object.
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The dictionary
     */
    public func toDictionary(_ conversionOptions: ConversionOptions = .DefaultSerialize) -> NSDictionary {
        if let obj = self as? NSObject {
            let (reflected, _) = EVReflection.toDictionary(obj, conversionOptions: conversionOptions)
            return reflected
        }
        evPrint(.ShouldExtendNSObject, "ERROR: You should only extend object with EVReflectable that are derived from NSObject!")
        return NSDictionary()
    }
    
    /**
     Convert this object to a json string
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The json string
     */
    public func toJsonString(_ conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false) -> String {
        let data = self.toJsonData(conversionOptions, prettyPrinted: prettyPrinted)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    /**
     Convert this object to a json Data
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The json Data
     */
    public func toJsonData(_ conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false) -> Data {
        var dict: NSDictionary
        
        // Custom or standard toDictionary
        if let v = self as? EVCustomReflectable {
            dict = v.toCodableValue() as? NSDictionary ?? NSDictionary()
        } else {
            dict = self.toDictionary(conversionOptions)
        }
        
        if let v = self as? NSObject {
            dict = EVReflection.convertDictionaryForJsonSerialization(dict, theObject: v)
        }
        
        do {
            if prettyPrinted {
                return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            }
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch { }
        return Data()
    }
    
    
    /**
     method for instantiating an array from a json string.
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: An array of objects
     */
    public static func arrayFromJson<T>(_ json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> [T] where T:NSObject {
        return EVReflection.arrayFromJson(type: T(), json: json, conversionOptions: conversionOptions)
    }
    
    /**
     Auto map an opbject to an object of an other type.
     Properties with the same name will be mapped automattically.
     Automattic cammpelCase, PascalCase, snake_case conversion
     Supports propperty mapping and conversion when using EVReflectable as a protocol
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The targe object with the mapped values
     */
    public func mapObjectTo<T>(_ conversionOptions: ConversionOptions = .DefaultDeserialize) -> T where T:NSObject {
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
    public func typeForKey(_ propertyName: String) -> Any.Type? {
        let mirror = Mirror(reflecting: self)
        return typeForKey(propertyName, mirror: mirror)
    }
    
    /**
     get the type of a property
     
     - parameter propertyName: The property key
     - parameter mirror:       The mirror of this object
     
     - returns: The type of the property
     */
    fileprivate func typeForKey(_ propertyName: String, mirror: Mirror) -> Any.Type? {
        for (label, value) in mirror.children {
            if propertyName == label {
                return Mirror(reflecting: value).subjectType
            }
        }
        
        guard let superclassMirror = mirror.superclassMirror else {
            return nil
        }
        
        return typeForKey(propertyName, mirror: superclassMirror)
    }
    
    
    /**
     Convert a Swift dictionary to a NSDictionary.
     
     - parameter key:  Key of the property that is the dictionary. Can be used when overriding this function
     - parameter dict: The Swift dictionary
     
     - returns: The dictionary converted to a NSDictionary
     */
    public func convertDictionary(_ key: String, dict: Any) -> NSDictionary {
        let returnDict = NSMutableDictionary()
        for (key, value) in dict as? NSDictionary ?? NSDictionary() {
            returnDict[key as? String ?? ""] = value
        }
        return returnDict
    }
    
    
    // MARK: - extending serialization status functions
    
    
    /**
     Validation function that you will probably call from the initValidation function. This function will make sure
     the passed on keys are not in the dictionary used for initialisation.
     The result of this validation is stored in evReflectionStatus.
     
     - parameter keys: The fields that may not be in the dictionary (like an error key)
     - parameter dict: The dictionary that is passed on from the initValidation function
     */
    public func initMayNotContainKeys(_ keys: [String], dict: NSDictionary) {
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
    public func initMustContainKeys(_ keys: [String], dict: NSDictionary) {
        for key in keys {
            if dict[key] == nil {
                addStatusMessage(.MissingKey, message: "Missing key: \(key)")
            }
        }
    }
    /**
     Return a merged status out of the status array
     
     - returns: the deserialization status for the object
     */
    public func evReflectionStatus() -> DeserializationStatus {
        var status: DeserializationStatus = .None
        for (s, _) in self.evReflectionStatuses {
            status = [status, s]
        }
        return status
    }
    
    /**
     function for adding a new status message to the evReflectionStatus array
     
     - parameter type:    A string to specify the message type
     - parameter message: The message for the status.
     */
    public func addStatusMessage(_ type: DeserializationStatus, message: String) {
        self.evReflectionStatuses.append((type, message))
    }    
}
