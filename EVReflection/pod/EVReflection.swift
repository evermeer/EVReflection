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
    
    :param: dictionary The dictionary that will be converted to an object
    :param: anyobjectTypeString The string representation of the object type that will be created
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
    
    :param: dictionary The dictionary that will be converted to an object
    :param: anyObject The object where the properties will be set
    :return: The object that is created from the dictionary
    */
    public class func setPropertiesfromDictionary<T where T:NSObject>(dictionary:NSDictionary, anyObject: T) -> T {
        var (hasKeys, hasTypes) = toDictionary(anyObject)
        for (k, v) in dictionary {
            if var key = k as? String {
                var skipKey = false
                var toKey = key
                if let evObject = anyObject as? EVObject {
                    if let mapping = filter(evObject.propertyMapping(), {$0.1 == key}).first {
                        if mapping.0 == nil {
                            skipKey = true
                        } else {
                            toKey = mapping.0!
                        }
                    }
                }
                if !skipKey{
                    var newValue: AnyObject? = dictionary[key]!
                    if let type = hasTypes[toKey] {
                        if type.hasPrefix("Swift.Array<") && newValue as? NSDictionary != nil {
                            if var value = v as? [NSObject] {
                                value.append(newValue! as! NSObject)
                                newValue = value
                            }
                        } else if type != "NSDictionary" && newValue as? NSDictionary != nil {
                            newValue = dictToObject(type, original:hasKeys[key] as! NSObject ,dict: newValue as! NSDictionary)
                        } else if type.rangeOfString("<NSDictionary>") == nil && newValue as? [NSDictionary] != nil {
                            newValue = dictArrayToObjectArray(type, array: newValue as! [NSDictionary]) as [NSObject]
                        }
                    }
                    let keywords = ["self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public", "internal", "zone"]
                    if contains(keywords, toKey) {
                        toKey = "_\(key)"
                    }
                    var error: NSError?
                    if anyObject.validateValue(&newValue, forKey: toKey, error: &error) {
                        if newValue == nil || newValue as? NSNull != nil {
                            anyObject.setValue(Optional.None, forKey: toKey)
                        } else {
                            // Let us put a number into a string property by taking it's stringValue
                            if let typeInObject = hasTypes[toKey] {
                                let (_, type) = valueForAny("", key: toKey, anyValue: newValue)
                                if (typeInObject == "Swift.String" || typeInObject == "NSString") && type == "NSNumber" {
                                    if let convertedValue = newValue as? NSNumber {
                                        newValue = convertedValue.stringValue
                                    }
                                }
                            }
                            // TODO: This will trigger setvalue for undefined key for specific types like enums, arrays of optionals or optional types.
                            anyObject.setValue(newValue, forKey: toKey)
                        }
                    }
                    
                }
            }
        }
        return anyObject
    }

    /**
    Set sub object properties from a dictionary
    
    :param: type The object type that will be created
    :param: dict The dictionary that will be converted to an object
    :return: The object that is created from the dictionary
    */
    private class func dictToObject<T where T:NSObject>(type:String, original:T ,dict:NSDictionary) -> T {
        var returnObject:NSObject = swiftClassFromString(type)
        returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject)
        return returnObject as! T
    }
    
    /**
    Create an Array of objects from an array of dictionaries
    
    :param: type The object type that will be created
    :param: array The array of dictionaries that will be converted to the array of objects
    :return: The array of objects that is created from the array of dictionaries
    */
    private class func dictArrayToObjectArray(type:String, array:[NSDictionary]) -> [NSObject] {
        var subtype = "EVObject"
        if (split(type) {$0 == "<"}).count > 1 {
            // Remove the Swift.Array prefix
            subtype = type.substringFromIndex((split(type) {$0 == "<"} [0] + "<").endIndex)
            subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
            
            // Remove the optional prefix from the subtype
            if subtype.hasPrefix("Swift.Optional<") {
                subtype = subtype.substringFromIndex((split(subtype) {$0 == "<"} [0] + "<").endIndex)
                subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
            }
        }

        var result = [NSObject]()
        for item in array {
            let arrayObject = self.dictToObject(subtype, original:swiftClassFromString(subtype), dict: item)
            result.append(arrayObject)
        }
        return result
    }
    
    /**
    Helper function that let us get the actual type of an object that is used inside an array
    
    :param: array The array of objects where we want the type of the object
    */
    private class func getArrayObjectType<T where T:NSObject>(array:[T]) -> String {
        return NSStringFromClass(T().dynamicType) as String
    }
    
    /**
    Convert an object to a dictionary
    
    :param: theObject The object that will be converted to a dictionary
    :return: The dictionary that is created from theObject plus a dictionary of propery types.
    */
    public class func toDictionary(theObject: NSObject) -> (NSDictionary, Dictionary<String,String>) {
        let reflected = reflect(theObject)
        return reflectedSub(theObject, reflected: reflected)
    }
    
    /**
    for parsing an object to a dictionary. including properties from it's super class (recursive)
    
    :param: reflected The object parsed using the reflect method.
    :return: The dictionary that is created from the object plus an dictionary of property types.
    */
    private class func reflectedSub(theObject:Any, reflected: MirrorType) -> (NSDictionary, Dictionary<String, String>) {
        var propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        var propertiesTypeDictionary : Dictionary<String,String> = Dictionary<String,String>()
        for i in 0..<reflected.count {
            let property = reflected[i]
            let key: String = property.0
            let mirrorType = property.1
            let value = mirrorType.value
            var valueType:String = ""
            if key != "super" || i != 0 {
                var skipKey = false
                var toKey = key
                if let evObject = theObject as? EVObject {
                    if let mapping = filter(evObject.propertyMapping(), {$0.0 == key}).first {
                        if mapping.1 == nil {
                            skipKey = true
                        } else {
                            toKey = mapping.1!
                        }
                    }
                }
                if !skipKey {
                    var (unboxedValue: AnyObject, valueType: String) = valueForAny(theObject, key: key, anyValue: value)
                    if unboxedValue as? EVObject != nil {
                        let (dict, _) = toDictionary(unboxedValue as! NSObject)
                        propertiesDictionary.setValue(dict, forKey: toKey)
                    } else if let array = unboxedValue as? [EVObject] {
                        var tempValue = [NSDictionary]()
                        for av in array {
                            let (dict, type) = toDictionary(av)
                            tempValue.append(dict)
                        }
                        unboxedValue = tempValue
                        propertiesDictionary.setValue(unboxedValue, forKey: toKey)
                    } else {
                        propertiesDictionary.setValue(unboxedValue, forKey: toKey)
                    }
                    propertiesTypeDictionary[toKey] = valueType
                }
            } else {
                let (addProperties,_) = reflectedSub(value, reflected: mirrorType)
                for (k, v) in addProperties {
                    propertiesDictionary.setValue(v, forKey: k as! String)
                }
            }
        }
        return (propertiesDictionary, propertiesTypeDictionary)
    }
    
    /**
    Dump the content of this object
    
    :param: theObject The object that will be loged
    */
    public class func logObject(theObject: NSObject) {
        NSLog(description(theObject))
    }
    
    /**
    Return a string representation of this object
    
    :param: theObject The object that will be loged
    :return: The string representation of the object
    */
    public class func description(theObject: NSObject) -> String {
        var description: String = swiftStringFromClass(theObject) + " {\n   hash = \(theObject.hash)\n"
        let (hasKeys, hasTypes) = toDictionary(theObject)
        for (key, value) in hasKeys {
            description = description  + "   key = \(key), value = \(value)\n"
        }
        description = description + "}\n"
        return description
    }
    
    
    /**
    Return a Json string representation of this object
    
    :param: theObject The object that will be loged
    :return: The string representation of the object
    */
    public class func toJsonString(theObject: NSObject) -> String {
        var (dict,_) = EVReflection.toDictionary(theObject)
        dict = convertDictionaryForJsonSerialization(dict)
        var error:NSError? = nil
        if var jsonData = NSJSONSerialization.dataWithJSONObject(dict , options: .PrettyPrinted, error: &error) {
            if var jsonString = NSString(data:jsonData, encoding:NSUTF8StringEncoding) {
                return jsonString as String
            }
        }
        return ""
    }
    
    /**
    Clean up dictionary so that it can be converted to json
    */
    private class func convertDictionaryForJsonSerialization(dict: NSDictionary) -> NSDictionary {
        for (key, value) in dict {
            dict.setValue(convertValueForJsonSerialization(value), forKey: key as! String)
        }
        return dict
    }
    
    /**
    Clean up a value so that it can be converted to json
    */
    private class func convertValueForJsonSerialization(value : AnyObject) -> AnyObject {
        switch(value) {
        case let stringValue as NSString:
            return stringValue
        case let numberValue as NSNumber:
            return numberValue
        case let nullValue as NSNull:
            return nullValue
        case let arrayValue as NSArray:
            var tempArray: NSMutableArray = NSMutableArray()
            for value in arrayValue {
                tempArray.addObject(convertValueForJsonSerialization(value))
            }
            return tempArray
        case let ok as NSDictionary:
            return convertDictionaryForJsonSerialization(ok)
        case let dateValue as NSDate:
            var dateFormatter = NSDateFormatter()
            return dateFormatter.stringFromDate(dateValue)
        case let recordIdValue as CKRecordID:
            return recordIdValue.recordName
        default:
            return "\(value)"
        }
    }
    
    /**
    Return a dictionary representation for the json string
    
    :param: json The json string that will be converted
    :return: The dictionary representation of the json
    */
    public class func dictionaryFromJson(json: String?) -> Dictionary<String, AnyObject> {
        if json == nil {
            return Dictionary<String, AnyObject>()
        }
        var error:NSError? = nil
        if let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding) {
            if let jsonDic = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? Dictionary<String, AnyObject> {
                return jsonDic
            }
        }
        return Dictionary<String, AnyObject>()
    }
    
    /**
    Return an array representation for the json string
    
    :param: json The json string that will be converted
    :return: The array of dictionaries representation of the json
    */
    public class func arrayFromJson<T where T:EVObject>(type:T, json: String?) -> [T] {
        if json == nil {
            return [T]()
        }
        var error:NSError? = nil
        if let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding) {
            if let jsonDic: [Dictionary<String, AnyObject>] = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? [Dictionary<String, AnyObject>] {
                return jsonDic.map({T(dictionary: $0)})
            }
        }
        return [T]()
    }
    
    
    /**
    Create a hashvalue for the object
    
    :param: theObject The object for what you want a hashvalue
    :return: the hashvalue for the object
    */
    public class func hashValue(theObject: NSObject) -> Int {
        let (hasKeys, hasTypes) = toDictionary(theObject)
        return Int(map(hasKeys) {$1}.reduce(0) {(31 &* $0) &+ $1.hash})
    }
    
    /**
    Get the swift Class type from a string
    
    :param: className The string representation of the class (name of the bundle dot name of the class)
    :return: The Class type
    */
    public class func swiftClassTypeFromString(className: String) -> AnyClass! {
        if className.hasPrefix("_TtC") {
            return NSClassFromString(className)
        }
        var classStringName = className
        if className.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch) == nil {
            var appName = getCleanAppName()
            classStringName = "\(appName).\(className)"
        }
        return NSClassFromString(classStringName)
    }
    
    /**
    Get the app name from the 'Bundle name' and if that's empty, then from the 'Bundle identifier' otherwise we assume it's a EVReflection unit test and use that bundle identifier
    :return: A cleaned up name of the app.
    */
    public class func getCleanAppName()-> String {
        var bundle = NSBundle.mainBundle()
        var appName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
        if appName == "" {
            if bundle.bundleIdentifier == nil {
                bundle = NSBundle(forClass: EVReflection().dynamicType)
            }
            appName = (split(bundle.bundleIdentifier!){$0 == "."}).last ?? ""
        }
        var cleanAppName = appName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return cleanAppName
    }
    
    /**
    Get the swift Class from a string
    
    :param: className The string representation of the class (name of the bundle dot name of the class)
    :return: The Class type
    */
    public class func swiftClassFromString(className: String) -> NSObject! {
        if className == "NSObject" {
            return NSObject()
        }
        let x: AnyClass! = swiftClassTypeFromString(className)
        if let anyobjectype : AnyObject.Type = swiftClassTypeFromString(className) {
            if let nsobjectype : NSObject.Type = anyobjectype as? NSObject.Type {
                var nsobject: NSObject = nsobjectype()
                return nsobject
            }
        }
        return nil
    }
    
    /**
    Get the class name as a string from a swift class
    
    :param: theObject An object for whitch the string representation of the class will be returned
    :return: The string representation of the class (name of the bundle dot name of the class)
    */
    public class func swiftStringFromClass(theObject: NSObject) -> String! {
        var appName = getCleanAppName()
        let classStringName: String = NSStringFromClass(theObject.dynamicType)
        let classWithoutAppName: String = classStringName.stringByReplacingOccurrencesOfString(appName + ".", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if classWithoutAppName.rangeOfString(".") != nil {
            NSLog("Warning! Your Bundle name should be the name of your target (set it to $(PRODUCT_NAME))")
            return (split(classWithoutAppName){$0 == "."}).last!
        }
        
        return classWithoutAppName
    }
    
    /**
    Encode any object
    
    :param: theObject The object that we want to encode.
    :param: aCoder The NSCoder that will be used for encoding the object.
    */
    public class func encodeWithCoder(theObject: NSObject, aCoder: NSCoder) {
        let (hasKeys, hasTypes) = toDictionary(theObject)
        for (key, value) in hasKeys {
            aCoder.encodeObject(value, forKey: key as! String)
        }
    }
    
    /**
    Decode any object
    
    :param: theObject The object that we want to decode.
    :param: aDecoder The NSCoder that will be used for decoding the object.
    */
    public class func decodeObjectWithCoder(theObject: NSObject, aDecoder: NSCoder) {
        let (hasKeys, hasTypes) = toDictionary(theObject)
        for (key, value) in hasKeys {
            if aDecoder.containsValueForKey(key as! String) {
                var newValue: AnyObject? = aDecoder.decodeObjectForKey(key as! String)
                if !(newValue is NSNull) {
                    if theObject.validateValue(&newValue, forKey: key as! String, error: nil) {
                        theObject.setValue(newValue, forKey: key as! String)
                    }
                }
            }
        }
    }
    
    /**
    Compare all fields of 2 objects
    
    :param: lhs The first object for the comparisson
    :param: rhs The second object for the comparisson
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
    
    /**
    Helper function to convert an Any to AnyObject
    
    :param: anyValue Something of type Any is converted to a type NSObject
    :return: The NSOBject that is created from the Any value plus the type of that value
    */
    public class func valueForAny(parentObject:Any, key:String, anyValue: Any) -> (AnyObject, String) {
        var theValue = anyValue
        var valueType = ""
        let mi: MirrorType = reflect(theValue)
        if mi.disposition == .Optional {
            if mi.count == 0 {
                var subtype: String = "\(mi)"
                subtype = subtype.substringFromIndex((split(subtype) {$0 == "<"} [0] + "<").endIndex)
                subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
                return (NSNull(), subtype)
            }
            theValue = mi[0].1.value
            valueType = "\(mi[0].1.valueType)"
        } else if mi.disposition == .Aggregate {
            //TODO: See if new Swift version can make using the EVRaw* protocols obsolete
            if let value = theValue as? EVRawString {
                return (value.rawValue, "\(mi.valueType)")
            }
            if let value = theValue as? EVRawInt {
                return (NSNumber(int: Int32(value.rawValue)), "\(mi.valueType)")
            }
            if let value = theValue as? EVRaw {
                if let returnValue = value.anyRawValue as? String {
                    return (returnValue, "\(mi.valueType)")
                }
            }
        } else if mi.disposition == .IndexContainer {
            valueType = "\(mi.valueType)"
            if valueType.hasPrefix("Swift.Array<Swift.Optional<") {
                //TODO: See if new Swift version can make using the EVArrayConvertable protocol obsolete
                if let arrayConverter = parentObject as? EVArrayConvertable {
                    let convertedValue = arrayConverter.convertArray(key, array: theValue)
                    return (convertedValue, valueType)
                } else {
                    NSLog("An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol.")
                }
            }
        } else {
            valueType = "\(mi.valueType)"
        }
        
        
        switch(theValue) {
        case let numValue as NSNumber:
            return (numValue, "NSNumber")
        case let doubleValue as Double:
            return (NSNumber(double: doubleValue), "NSNumber")
        case let floatValue as Float:
            return (NSNumber(float: floatValue), "NSNumber")
        case let longValue as Int64:
            return (NSNumber(longLong: longValue), "NSNumber")
        case let longValue as UInt64:
            return (NSNumber(unsignedLongLong: longValue), "NSNumber")
        case let intValue as Int32:
            return (NSNumber(int: intValue), "NSNumber")
        case let intValue as UInt32:
            return (NSNumber(unsignedInt: intValue), "NSNumber")
        case let intValue as Int16:
            return (NSNumber(short: intValue), "NSNumber")
        case let intValue as UInt16:
            return (NSNumber(unsignedShort: intValue), "NSNumber")
        case let intValue as Int8:
            return (NSNumber(char: intValue), "NSNumber")
        case let intValue as UInt8:
            return (NSNumber(unsignedChar: intValue), "NSNumber")
        case let intValue as Int:
            return (NSNumber(integer: intValue), "NSNumber")
        case let intValue as UInt:
            return (NSNumber(unsignedLong: intValue), "NSNumber")
        case let stringValue as String:
            return (stringValue as NSString, "NSString")
        case let boolValue as Bool:
            return (NSNumber(bool: boolValue), "NSNumber")
        case let anyvalue as NSObject:
            return (anyvalue, valueType)
        default:
            NSLog("ERROR: valueForAny unkown type \(theValue), type \(valueType)")
            return (NSNull(), "NSObject") // Could not happen
        }
        
    }
}
