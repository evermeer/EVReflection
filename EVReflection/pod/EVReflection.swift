//
//  EVReflection.swift
//
//  Created by Edwin Vermeer on 28-09-14.
//  Copyright (c) 2014 EVICT BV. All rights reserved.
//

import Foundation
import CloudKit

/**
Reflection methods
*/
final public class EVReflection {

    /**
    Create an object from a dictionary

    - parameter dictionary: The dictionary that will be converted to an object
    - parameter anyobjectTypeString: The string representation of the object type that will be created
    :return: The object that is created from the dictionary
    */
    public class func fromDictionary(dictionary:NSDictionary, anyobjectTypeString: String) -> NSObject? {
        if var nsobject = swiftClassFromString(anyobjectTypeString) {
            nsobject = setPropertiesfromDictionary(dictionary, anyObject: nsobject)
            return nsobject
        }
        return nil
    }

    /**
    Set object properties from a dictionary

    - parameter dictionary: The dictionary that will be converted to an object
    - parameter anyObject: The object where the properties will be set
    :return: The object that is created from the dictionary
    */
    public class func setPropertiesfromDictionary<T where T:NSObject>(dictionary:NSDictionary, anyObject: T) -> T {
        var (hasKeys, hasTypes) = toDictionary(anyObject)
        for (k, _) in dictionary {
            if var key = k as? String {
                var newValue: AnyObject? = dictionary[key]!
                if hasTypes[key] != "NSDictionary" && newValue as? NSDictionary != nil {
                    if let type = hasTypes[key] {
                        newValue = dictToObject(type, original:hasKeys[key] as! NSObject ,dict: newValue as! NSDictionary)
                    }
                } else if hasTypes[key]?.rangeOfString("<NSDictionary>") == nil && newValue as? [NSDictionary] != nil {
                    if let type:String = hasTypes[key] {
                        newValue = dictArrayToObjectArray(type, array: newValue as! [NSDictionary]) as [NSObject]
                    }
                }
                if (["self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet"].filter {$0 == key}).count > 0 {
                    key = "_\(key)"
                }
                do {
                    try anyObject.validateValue(&newValue, forKey: key)
                    if newValue == nil || newValue as? NSNull != nil {
                        anyObject.setValue(Optional.None, forKey: key)
                    } else {
                        anyObject.setValue(newValue, forKey: key)
                    }
                } catch _ as NSError { }
            }
        }
        return anyObject
    }
    
    /**
    Set sub object properties from a dictionary
    
    - parameter type: The object type that will be created
    - parameter dict: The dictionary that will be converted to an object
    :return: The object that is created from the dictionary
    */
    private class func dictToObject<T where T:NSObject>(type:String, original:T ,dict:NSDictionary) -> T {
        if var returnObject:NSObject = swiftClassFromString(type) {
            returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject)
            return returnObject as! T
        } else {
            let returnObject = setPropertiesfromDictionary(dict, anyObject: T())
            return returnObject
        }
    }
    
    /**
    Create an Array of objects from an array of dictionaries
    
    - parameter type: The object type that will be created
    - parameter array: The array of dictionaries that will be converted to the array of objects
    :return: The array of objects that is created from the array of dictionaries
    */
    private class func dictArrayToObjectArray(type:String, array:[NSDictionary]) -> [NSObject] {
        let subtype: String = (split(type.characters) {$0 == "<"}.map { String($0) } [1]).stringByReplacingOccurrencesOfString(">", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var result = [NSObject]()
        for item in array {
            let arrayObject = self.dictToObject(subtype, original:swiftClassFromString(subtype), dict: item)
            result.append(arrayObject)
        }
        return result
    }
    
    /**
    Helper function that let us get the actual type of an object that is used inside an array
    
    - parameter array: The array of objects where we want the type of the object
    */
    private class func getArrayObjectType<T where T:NSObject>(array:[T]) -> String {
        return NSStringFromClass(T().dynamicType) as String
    }
    
    /**
    Convert an object to a dictionary

    - parameter theObject: The object that will be converted to a dictionary
    :return: The dictionary that is created from theObject plus a dictionary of propery types.
    */
    public class func toDictionary(theObject: NSObject) -> (NSDictionary, Dictionary<String,String>) {
        let reflected = reflect(theObject)
        return reflectedSub(reflected)
    }
    
    /**
    for parsing an object to a dictionary. including properties from it's super class (recursive)

    - parameter reflected: The object parsed using the reflect method.
    :return: The dictionary that is created from the object plus an dictionary of property types.
    */
    private class func reflectedSub(reflected: MirrorType) -> (NSDictionary, Dictionary<String, String>) {
        let propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        var propertiesTypeDictionary : Dictionary<String,String> = Dictionary<String,String>()
        for i in 0..<reflected.count {
            let key: String = reflected[i].0
            let value = reflected[i].1.value
            if key != "super" || i != 0 {
                var (unboxedValue, valueType): (AnyObject, String) = valueForAny(value)
                if unboxedValue as? EVObject != nil {
                    let (dict, _) = toDictionary(unboxedValue as! NSObject)
                    propertiesDictionary.setValue(dict, forKey: key)
                } else if let array = unboxedValue as? [EVObject] {
                    var tempValue = [NSDictionary]()
                    for av in array {
                        let (dict, _) = toDictionary(av)
                        tempValue.append(dict)
                    }
                    unboxedValue = tempValue
                    propertiesDictionary.setValue(unboxedValue, forKey: key)
                } else {
                    propertiesDictionary.setValue(unboxedValue, forKey: key)
                }
                propertiesTypeDictionary[key] = valueType
            } else {
                let superReflected = reflected[i].1
                let (addProperties,_) = reflectedSub(superReflected)
                for (k, v) in addProperties {
                    propertiesDictionary.setValue(v, forKey: k as! String)
                }
            }
        }
        return (propertiesDictionary, propertiesTypeDictionary)
    }

    /**
    Dump the content of this object

    - parameter theObject: The object that will be loged
    */
    public class func logObject(theObject: NSObject) {
        NSLog(description(theObject))
    }

    /**
    Return a string representation of this object

    - parameter theObject: The object that will be loged
    :return: The string representation of the object
    */
    public class func description(theObject: NSObject) -> String {
        var description: String = swiftStringFromClass(theObject) + " {\n   hash = \(theObject.hash)\n"
        let (hasKeys, _) = toDictionary(theObject)
        for (key, value) in hasKeys {
            description = description  + "   key = \(key), value = \(value)\n"
        }
        description = description + "}\n"
        return description
    }

    
    /**
    Return a Json string representation of this object
    
    - parameter theObject: The object that will be loged
    :return: The string representation of the object
    */
    public class func toJsonString(theObject: NSObject) -> String {
        let (dict,_) = EVReflection.toDictionary(theObject)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict , options: .PrettyPrinted)
            if let jsonString = NSString(data:jsonData, encoding:NSUTF8StringEncoding) {
                return jsonString as String
            }
        } catch _ as NSError { }
        return ""
    }
    
    /**
    Return a dictionary representation for the json string
    
    - parameter json: The json string that will be converted
    :return: The dictionary representation of the json
    */
    public class func dictionaryFromJson(json: String) -> Dictionary<String, AnyObject> {
        if let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                    return jsonDic
                }
            } catch _ as NSError { }
        }
        return Dictionary<String, AnyObject>()
    }

    /**
    Return an array representation for the json string
    
    - parameter json: The json string that will be converted
    :return: The array of dictionaries representation of the json
    */
    public class func arrayFromJson<T where T:EVObject>(type:T, json: String) -> [T] {
        if let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let jsonDic: [Dictionary<String, AnyObject>] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? [Dictionary<String, AnyObject>] {
                    return jsonDic.map({T(dictionary: $0)})
                }
            } catch _ as NSError { }
        }
        return [T]()
    }
    
    
    /**
    Create a hashvalue for the object

    - parameter theObject: The object for what you want a hashvalue
    :return: the hashvalue for the object
    */
    public class func hashValue(theObject: NSObject) -> Int {
        let (hasKeys, _) = toDictionary(theObject)
        return Int(hasKeys.map {$1}.reduce(0) {(31 &* $0) &+ $1.hash})
    }

    /**
    Get the swift Class type from a string

    - parameter className: The string representation of the class (name of the bundle dot name of the class)
    :return: The Class type
    */
    public class func swiftClassTypeFromString(className: String) -> AnyClass! {
        if className.hasPrefix("_TtC") {
            return NSClassFromString(className)
        }
        var classStringName = className
        if className.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch) == nil {
            let appName = getCleanAppName()
            classStringName = "\(appName).\(className)"
        }
        return NSClassFromString(classStringName)
    }

    /**
    Get the app name from the 'Bundle name' and if that's empty, then from the 'Bundle identifier' otherwise we assume it's a EVReflection unit test and use that bundle identifier
    :return: A cleaned up name of the app.
    */
    private class func getCleanAppName()-> String {
        var bundle = NSBundle.mainBundle()
        var appName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
        if appName == "" {
            if bundle.bundleIdentifier == nil {
                bundle = NSBundle(forClass: EVReflection().dynamicType)
            }
            appName = (split((bundle.bundleIdentifier!).characters){$0 == "."}.map { String($0) }).last ?? ""
        }
        let cleanAppName = appName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return cleanAppName
    }

    /**
    Get the swift Class from a string

    - parameter className: The string representation of the class (name of the bundle dot name of the class)
    :return: The Class type
    */
    public class func swiftClassFromString(className: String) -> NSObject! {
        if className == "NSObject" {
            return NSObject()
        }
        if let anyobjectype : AnyObject.Type = swiftClassTypeFromString(className) {
            if let nsobjectype : NSObject.Type = anyobjectype as? NSObject.Type {
                let nsobject: NSObject = nsobjectype.init()
                return nsobject
            }
        }
        return nil
    }

    /**
    Get the class name as a string from a swift class

    - parameter theObject: An object for whitch the string representation of the class will be returned
    :return: The string representation of the class (name of the bundle dot name of the class)
    */
    public class func swiftStringFromClass(theObject: NSObject) -> String! {
        let appName = getCleanAppName()
        let classStringName: String = NSStringFromClass(theObject.dynamicType)
        let classWithoutAppName: String = classStringName.stringByReplacingOccurrencesOfString(appName + ".", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if classWithoutAppName.rangeOfString(".") != nil {
            NSLog("Warning! Your Bundle name should be the name of your target (set it to $(PRODUCT_NAME))")
            let parts = split(classWithoutAppName.characters){$0 == "."}
            let strings: [String] = parts.map { String($0) }
            return strings.last!
        }
        return classWithoutAppName
    }

    /**
    Encode any object

    - parameter theObject: The object that we want to encode.
    - parameter aCoder: The NSCoder that will be used for encoding the object.
    */
    public class func encodeWithCoder(theObject: NSObject, aCoder: NSCoder) {
        let (hasKeys, _) = toDictionary(theObject)
        for (key, value) in hasKeys {
            aCoder.encodeObject(value, forKey: key as! String)
        }
    }

    /**
    Decode any object

    - parameter theObject: The object that we want to decode.
    - parameter aDecoder: The NSCoder that will be used for decoding the object.
    */
    public class func decodeObjectWithCoder(theObject: NSObject, aDecoder: NSCoder) {
        let (hasKeys, _) = toDictionary(theObject)
        for (key, _) in hasKeys {
            if aDecoder.containsValueForKey(key as! String) {
                var newValue: AnyObject? = aDecoder.decodeObjectForKey(key as! String)
                if !(newValue is NSNull) {
                    do {
                        try theObject.validateValue(&newValue, forKey: key as! String)
                        theObject.setValue(newValue, forKey: key as! String)
                    } catch _ {
                    }
                }
            }
        }
    }

    /**
    Compare all fields of 2 objects

    - parameter lhs: The first object for the comparisson
    - parameter rhs: The second object for the comparisson
    :return: true if the objects are the same, otherwise false
    */
    public class func areEqual(lhs: NSObject, rhs: NSObject) -> Bool {
        if swiftStringFromClass(lhs) != swiftStringFromClass(rhs) {
            return false;
        }

        let (lhsdict,_) = toDictionary(lhs)
        let (rhsdict,_) = toDictionary(rhs)

        for (key, value) in rhsdict {
            if let compareTo: AnyObject = lhsdict[key as! String] {
                if !compareTo.isEqual(value) {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }

    //TODO: Make this work with nulable types
    /**
    Helper function to convert an Any to AnyObject

    - parameter anyValue: Something of type Any is converted to a type NSObject
    :return: The NSOBject that is created from the Any value plus the type of that value
    */
    public class func valueForAny(anyValue: Any) -> (AnyObject, String) {
        var theValue = anyValue
        let mi: MirrorType = reflect(theValue)
        if mi.disposition == .Optional {
          if mi.count == 0 {
            let subtype: String = (split("\(mi.valueType)".characters) {$0 == "<"}
                .map { String($0) } [1])
                .stringByReplacingOccurrencesOfString(">", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            return (NSNull(), subtype)
          }
          let (_,some) = mi[0]
          theValue = some.value
        }
        let valueType = "\(mi.valueType)"

        switch(theValue) {
        case let longValue as Int64:
            return (NSNumber(long: CLong(longValue)), "NSNumber")
        case let intValue as Int:
            return (NSNumber(int: CInt(intValue)), "NSNumber")
        case let doubleValue as Double:
            return (NSNumber(double: CDouble(doubleValue)), "NSNumber")
        case let stringValue as String:
            return (stringValue as NSString, "NSString")
        case let boolValue as Bool:
            return (NSNumber(bool: boolValue), "NSNumber")
        case let anyvalue as NSObject:
            return (anyvalue, valueType)
        default:
            NSLog("ERROR: valueForAny unkown type \(theValue)")
            return (NSNull(), "NSObject") // Could not happen
        }
    }
}
