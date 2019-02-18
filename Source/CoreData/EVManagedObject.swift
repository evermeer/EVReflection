//
//  NSManagedObjectEVReflectable.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2017 evict. All rights reserved.
//

import CoreData

@objcMembers
@objc open class EVManagedObject: NSManagedObject, EVReflectable {

    /**
     Implementation of a required initializer which is required by NSManagedObject
     
     - parameter entityName: The CoreData entityName
     - parameter insertIntoManagedObjectContext: the managed object context
     - parameter json: The json string for populating the properties
     - parameter forKeyPath: keypath in the json for if not the root object needs to be used.
     */
    @discardableResult
    public required init(entityName: String? = nil,
                                     context: NSManagedObjectContext!,
                                     json: String?,
                                     forKeyPath: String? = nil) {
        let t=type(of: self)
        let name = entityName ?? EVReflection.swiftStringFromClass(t)
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)
        super.init(entity: entity!, insertInto: context)
        
        let jsonDictionary = EVReflection.dictionaryFromJson(json)
        
        EVReflection.setPropertiesfromDictionary(jsonDictionary, anyObject: self, forKeyPath: forKeyPath)
    }
    
    public required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - overrides because no Mirror support
    // overrides because Mirror is not supported for NSManagedObject. Instead we use obj.dictionaryWithValues(forKeys: obj.entity.attributesByName.keys)
    
    /**
     Returns the pritty description of this object
     
     - returns: The pritty description
     */
    open override var description: String {
        get {
            return "\(EVReflection.swiftStringFromClass(self)) = \(self.toJsonString(prettyPrinted: true))"
        }
    }
    
    /**
     Returns the pritty description of this object
     
     - returns: The pritty description
     */
    open override var debugDescription: String {
        get {
            return self.description
        }
    }
    
    open func toDictionary(_ conversionOptions: ConversionOptions = .DefaultSerialize) -> NSDictionary {
        let keys = Array(self.entity.attributesByName.keys)
        return self.dictionaryWithValues(forKeys: keys) as NSDictionary
    }

    // MARK: - copy of EVReflectable functions.

    // These functions are also here becaue they would otherwise call the toDictionary in the protocol instead of here
    
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
        let dict: NSDictionary = self.toDictionary(conversionOptions)
        do {
            if prettyPrinted {
                return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            }
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            evPrint(.IsInvalidJson, "ERROR: Could not create json data from dictionary")
        }
        return Data()
    }
    
    // MARK: - copy of EVObject functions.
    
    // Below is a copy of all functions that are also implemented in EVObject. These are also here because we cannot have multiple enheritence. (Both NSManagedObject and EVObject) Only the init() has to be removed
    

    
    /**
     Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter value: The value that you wanted to set
     - parameter key: The name of the property that you wanted to set
     */
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let kvc = self as? EVGenericsKVC {
            kvc.setGenericValue(value as AnyObject?, forUndefinedKey: key)
        } else {
            self.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            evPrint(.IncorrectKey, "\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
            
        }
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
    open func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
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
    
    
    /**
     Return a custom object for the object
     
     - returns: The custom object (single value, dictionary or array)
     */
    open func customConverter() -> AnyObject? {
        return nil
    }
    
}
