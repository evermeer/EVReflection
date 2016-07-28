//
//  EVReflection.swift
//
//  Created by Edwin Vermeer on 28-09-14.
//  Copyright (c) 2014 EVICT BV. All rights reserved.
//

import Foundation


/**
 Reflection methods
 */
final public class EVReflection {
    
    // MARK: - From and to Dictrionary parsing
    
    
    /**
    Create an object from a dictionary
    
    - parameter dictionary: The dictionary that will be converted to an object
    - parameter anyobjectTypeString: The string representation of the object type that will be created
    - parameter conversionOptions: Option set for the various conversion options.
     
    - returns: The object that is created from the dictionary
    */
    public class func fromDictionary(dictionary: NSDictionary, anyobjectTypeString: String, conversionOptions: ConversionOptions = .DefaultDeserialize) -> NSObject? {
        if var nsobject = swiftClassFromString(anyobjectTypeString) {
            if let evResult = nsobject as? EVObject {
                nsobject = evResult.getSpecificType(dictionary)
            }
            nsobject = setPropertiesfromDictionary(dictionary, anyObject: nsobject, conversionOptions: conversionOptions)
            return nsobject
        }
        return nil
    }
    
    
    /**
     Set object properties from a dictionary
     
     - parameter dictionary: The dictionary that will be converted to an object
     - parameter anyObject: The object where the properties will be set
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The object that is created from the dictionary
     */
    public class func setPropertiesfromDictionary<T where T: NSObject>(dictionary: NSDictionary, anyObject: T, conversionOptions: ConversionOptions = .DefaultDeserialize) -> T {
        autoreleasepool {
            (anyObject as? EVObject)?.initValidation(dictionary)
            let (keyMapping, _, types) = getKeyMapping(anyObject, dictionary: dictionary, conversionOptions: .PropertyMapping)
            for (k, v) in dictionary {
                var skipKey = false
                if conversionOptions.contains(.PropertyMapping) {
                    if let evObject = anyObject as? EVObject {
                        if let mapping = evObject.propertyMapping().filter({$0.0 == k as? String}).first {
                            if mapping.1 == nil {
                                skipKey = true
                            }
                        }
                    }
                }
                if !skipKey {
                    let objectKey = k as? String ?? ""
                    let mapping = keyMapping[objectKey]
                    let useKey: String = (mapping ?? objectKey) as? String ?? ""
                    let original: NSObject? = getValue(anyObject, key: useKey)
                    let dictKey: String = cleanupKey(anyObject, key: objectKey, tryMatch: types) ?? ""
                    let (dictValue, valid) = dictionaryAndArrayConversion(anyObject, key: objectKey, fieldType: types[dictKey] as? String ?? types[useKey] as? String, original: original, theDictValue: v, conversionOptions: conversionOptions)
                    if dictValue != nil {
                        if let key: String = keyMapping[k as? String ?? ""] as? String {
                            setObjectValue(anyObject, key: key, theValue: (valid ? dictValue: v), typeInObject: types[key] as? String, valid: valid, conversionOptions: conversionOptions)
                        } else {
                            setObjectValue(anyObject, key: k as? String ?? "", theValue: (valid ? dictValue : v), typeInObject: types[k as? String ?? ""] as? String, valid: valid, conversionOptions: conversionOptions)
                        }
                    }
                }
            }
        }
        return anyObject
    }
    
    public class func getValue(fromObject: NSObject, key: String) -> NSObject? {
        if let mapping = (Mirror(reflecting: fromObject).children.filter({$0.0 == key}).first) {
            if let value = mapping.value as? NSObject {
                return value                
            }
        }
        return nil
    }
    
    /**
     Based on an object and a dictionary create a keymapping plus a dictionary of properties plus a dictionary of types
     
     - parameter anyObject:  the object for the mapping
     - parameter dictionary: the dictionary that has to be mapped
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The mapping, keys and values of all properties to items in a dictionary
     */
    private static func getKeyMapping<T where T: NSObject>(anyObject: T, dictionary: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (keyMapping: NSDictionary, properties: NSDictionary, types: NSDictionary) {
        let (properties, types) = toDictionary(anyObject, conversionOptions: conversionOptions, isCachable: true)
        var keyMapping: Dictionary<String, String> = Dictionary<String, String>()
        for (objectKey, _) in properties {
            if conversionOptions.contains(.PropertyMapping) {
                if let evObject = anyObject as? EVObject {
                    if let mapping = evObject.propertyMapping().filter({$0.1 == objectKey as? String}).first {
                        keyMapping[objectKey as? String ?? ""] = mapping.0
                    }
                }
            }
            
            if let dictKey = cleanupKey(anyObject, key: objectKey as? String ?? "", tryMatch: dictionary) {
                if dictKey != objectKey  as? String {
                    keyMapping[dictKey] = objectKey as? String
                }
            }
        }
        return (keyMapping, properties, types)
    }
    
    
    static var properiesCache = NSMutableDictionary()
    static var typesCache = NSMutableDictionary()
    
    /**
     Convert an object to a dictionary while cleaning up the keys
     
     - parameter theObject: The object that will be converted to a dictionary
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The dictionary that is created from theObject plus a dictionary of propery types.
     */
    public class func toDictionary(theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize, isCachable: Bool = false, parents: [NSObject] = []) -> (NSDictionary, NSDictionary) {
        var pdict: NSDictionary?
        var tdict: NSDictionary?

        var i = 1
        for parent in parents {
            if parent === theObject {
                pdict = NSMutableDictionary()
                pdict!.setValue("\(i)", forKey: "_EVReflection_parent_")
                tdict = NSMutableDictionary()
                tdict!.setValue("NSString", forKey: "_EVReflection_parent_")
                return (pdict!, tdict!)
            }
            i = i + 1
        }
        var theParents = parents
        theParents.append(theObject)
        
        let key: String = "\(theObject.dynamicType).\(conversionOptions.rawValue)"
        if isCachable {
            if let p = properiesCache[key] as? NSDictionary, let t = typesCache[key] as? NSDictionary {
                return (p, t)
            }
        }
        autoreleasepool {
            let reflected = Mirror(reflecting: theObject)
            var (properties, types) =  reflectedSub(theObject, reflected: reflected, conversionOptions: conversionOptions, isCachable: isCachable, parents: theParents)
            if conversionOptions.contains(.KeyCleanup) {
                 (properties, types) = cleanupKeysAndValues(theObject, properties:properties, types:types)
            }
            pdict = properties
            tdict = types
        }
        if isCachable && typesCache[key] == nil {
            properiesCache[key] = pdict!
            typesCache[key] = tdict!
        }
        return (pdict!, tdict!)
    }
    
    
    // MARK: - From and to JSON parsing
    
    /**
    Return a dictionary representation for the json string
    
    - parameter json: The json string that will be converted
    
    - returns: The dictionary representation of the json
    */
    public class func dictionaryFromJson(json: String?) -> NSDictionary {
        var result = NSDictionary()
        if json == nil {
            return result
        }
        if let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    result = jsonDic
                }
            } catch _ as NSError { }
        }
        return result
    }
    
    /**
     Return an array representation for the json string
     
     - parameter type: An instance of the type where the array will be created of.
     - parameter json: The json string that will be converted
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The array of dictionaries representation of the json
     */
    public class func arrayFromJson<T>(theObject: NSObject? = nil, type: T, json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> [T] {
        var result = [T]()
        if json == nil {
            return result
        }
        let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            if let jsonDic: [Dictionary<String, AnyObject>] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? [Dictionary<String, AnyObject>] {
                let nsobjectype: NSObject.Type? = T.self as? NSObject.Type
                if nsobjectype == nil {
                    print("WARNING: EVReflection can only be used with types with NSObject as it's minimal base type")
                    return result
                }
                result = jsonDic.map({
                    let nsobject: NSObject = nsobjectype!.init()
                    return (setPropertiesfromDictionary($0, anyObject: nsobject, conversionOptions: conversionOptions) as? T)!
                })
            }
        } catch _ as NSError {}
        return result
    }
    
    /**
     Return a Json string representation of this object
     
     - parameter theObject: The object that will be loged
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The string representation of the object
     */
    public class func toJsonString(theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize) -> String {
        var result: String = ""
        autoreleasepool {
            var (dict, _) = EVReflection.toDictionary(theObject, conversionOptions: conversionOptions)
            dict = convertDictionaryForJsonSerialization(dict, theObject: theObject)
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
                if let jsonString = NSString(data:jsonData, encoding:NSUTF8StringEncoding) {
                    result =  jsonString as String
                }
            } catch { }
        }
        return result
    }
    
    
    // MARK: - Adding functionality to objects
    
    /**
    Dump the content of this object to the output
    
    - parameter theObject: The object that will be loged
    */
    public class func logObject(theObject: NSObject) {
        NSLog(description(theObject))
    }
    
    /**
     Return a string representation of this object
     
     - parameter theObject: The object that will be loged
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The string representation of the object
     */
    public class func description(theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize) -> String {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: conversionOptions)

        var description: String = (swiftStringFromClass(theObject) ?? "?") + " {\n   hash = \(hashValue(theObject))"
        description = description + hasKeys.map {"   \($0) = \($1)"}.reduce("") {"\($0)\n\($1)"} + "\n}\n"
        return description
    }
    
    /**
     Create a hashvalue for the object
     
     - parameter theObject: The object for what you want a hashvalue
     
     - returns: the hashvalue for the object
     */
    public class func hashValue(theObject: NSObject) -> Int {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: .DefaultComparing)
        return Int(hasKeys.map {$1}.reduce(0) {(31 &* $0) &+ $1.hash})
    }
    
    
    /**
     Encode any object
     
     - parameter theObject: The object that we want to encode.
     - parameter aCoder: The NSCoder that will be used for encoding the object.
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public class func encodeWithCoder(theObject: EVObject, aCoder: NSCoder, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: conversionOptions)
        for (key, value) in hasKeys {
            aCoder.encodeObject(value, forKey: key as? String ?? "")
        }
    }
    
    /**
     Decode any object
     
     - parameter theObject: The object that we want to decode.
     - parameter aDecoder: The NSCoder that will be used for decoding the object.
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public class func decodeObjectWithCoder(theObject: EVObject, aDecoder: NSCoder, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: conversionOptions, isCachable: true)
        let dict = NSMutableDictionary()
        for (key, _) in hasKeys {
            if aDecoder.containsValueForKey((key as? String)!) {
                let newValue: AnyObject? = aDecoder.decodeObjectForKey((key as? String)!)
                if !(newValue is NSNull) {
                    dict[(key as? String)!] = newValue
                }
            }
        }
        EVReflection.setPropertiesfromDictionary(dict, anyObject: theObject, conversionOptions: conversionOptions)
    }
    
    /**
     Compare all fields of 2 objects
     
     - parameter lhs: The first object for the comparisson
     - parameter rhs: The second object for the comparisson
     
     - returns: true if the objects are the same, otherwise false
     */
    public class func areEqual(lhs: NSObject, rhs: NSObject) -> Bool {
        if swiftStringFromClass(lhs) != swiftStringFromClass(rhs) {
            return false
        }
        
        let (lhsdict, _) = toDictionary(lhs, conversionOptions: .DefaultComparing)
        let (rhsdict, _) = toDictionary(rhs, conversionOptions: .DefaultComparing)
        
        return dictionariesAreEqual(lhsdict, rhsdict: rhsdict)
    }
    

    /**
     Compare 2 dictionaries
     
     - parameter lhsdict: Compare this dictionary
     - parameter rhsdict: Compare with this dictionary
     
     - returns: Are the dictionaries equal or not
     */
    public class func dictionariesAreEqual(lhsdict: NSDictionary, rhsdict: NSDictionary) -> Bool {
        for (key, value) in rhsdict {
            if let compareTo = lhsdict[(key as? String)!] {
                if let dateCompareTo = compareTo as? NSDate, dateValue = value as? NSDate {
                    let t1 = Int64(dateCompareTo.timeIntervalSince1970)
                    let t2 = Int64(dateValue.timeIntervalSince1970)
                    if t1 != t2 {
                        return false
                    }
                } else if let array = compareTo as? NSArray, arr = value as? NSArray {
                    if arr.count != array.count {
                        return false
                    }
                    for (index, arrayValue) in array.enumerate() {
                        if arrayValue as? NSDictionary != nil {
                            if !dictionariesAreEqual((arrayValue as? NSDictionary)!, rhsdict: (arr[index] as? NSDictionary)!) {
                                return false
                            }
                        } else {
                            if !arrayValue.isEqual(arr[index]) {
                                return false
                            }
                        }
                    }
                } else if !compareTo.isEqual(value) {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Reflection helper functions
    
    /**
    Get the app name from the 'Bundle name' and if that's empty, then from the 'Bundle identifier' otherwise we assume it's a EVReflection unit test and use that bundle identifier
    
    - parameter forObject: Pass an object to this method if you know a class from the bundele where you want the name for.
    
    - returns: A cleaned up name of the app.
    */
    public class func getCleanAppName(forObject: NSObject? = nil) -> String {
        // if an object was specified, then always use the bundle name of that class
        if forObject != nil {
            return nameForBundle(NSBundle(forClass: forObject!.dynamicType))
        }
        
        // If no object was specified but an identifier was set, then use that identifier.
        if EVReflection.bundleIdentifier != nil {
            return EVReflection.bundleIdentifier!
        }
        
        // use the bundle name from the main bundle, if that's not set use the identifier
        return nameForBundle(NSBundle.mainBundle())
    }
    
    /// Variable that can be set using setBundleIdentifier
    private static var bundleIdentifier: String? = nil
    
    /// Variable that can be set using setBundleIdentifiers
    private static var bundleIdentifiers: [String]? = nil
    
    /**
     This method can be used in unit tests to force the bundle where classes can be found
     
     - parameter forClass: The class that will be used to find the appName for in which we can find classes by string.
     */
    public class func setBundleIdentifier(forClass: AnyClass) {
        if let bundle: NSBundle = NSBundle(forClass:forClass) {
            EVReflection.bundleIdentifier = nameForBundle(bundle)
        }
    }
    
    /**
     This method can be used in project where models are split between multiple modules.
     
     - parameter classes: classes that that will be used to find the appName for in which we can find classes by string.
     */
    public class func setBundleIdentifiers(classes: Array<AnyClass>) {
        bundleIdentifiers = []
        for aClass in classes {
            if let bundle: NSBundle = NSBundle(forClass: aClass) {
                bundleIdentifiers?.append(nameForBundle(bundle))
            }
        }
    }
    
    private static func nameForBundle(bundle: NSBundle) -> String {
        // get the bundle name from what is set in the infoDictionary
        var appName = bundle.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
        
        // If it was not set, then use the bundleIdentifier (which is the same as kCFBundleIdentifierKey)
        if appName == "" {
            appName = bundle.bundleIdentifier ?? ""
        }
        appName = appName.characters.split(isSeparator: {$0 == "."}).map({ String($0) }).last ?? ""
        
        // Clean up special characters
        return appName.componentsSeparatedByCharactersInSet(illegalCharacterSet).joinWithSeparator("_")
    }

    
    /// This dateformatter will be used when a conversion from string to NSDate is required
    private static var dateFormatter: NSDateFormatter? = nil
    
    /**
     This function can be used to force using an alternat dateformatter for converting String to NSDate
     
     - parameter formatter: The new DateFormatter
     */
    public class func setDateFormatter(formatter: NSDateFormatter?) {
        dateFormatter = formatter
    }
    
    /**
     This function is used for getting the dateformatter and defaulting to a standard if it's not set
     
     - returns: The dateformatter
     */
    private class func getDateFormatter() -> NSDateFormatter {
        if let formatter = dateFormatter {
            return formatter
        }
        dateFormatter = NSDateFormatter()
        dateFormatter!.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter!.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        return dateFormatter!
    }
    
    /**
     Get the swift Class type from a string
     
     - parameter className: The string representation of the class (name of the bundle dot name of the class)
     
     - returns: The Class type
     */
    public class func swiftClassTypeFromString(className: String) -> AnyClass? {
        if let c = NSClassFromString(className) {
            return c
        }
        
        // The default did not work. try a combi of appname and classname
        if className.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch) == nil {
            let appName = getCleanAppName()
            if let c = NSClassFromString("\(appName).\(className)") {
                return c
            }
        }
        
        if let bundleIdentifiers = bundleIdentifiers {
            for aBundle in bundleIdentifiers {
                if let existingClass = NSClassFromString("\(aBundle).\(className)") {
                    return existingClass
                }
            }
        }
        
        return nil
    }
    
    /**
     Get the swift Class from a string
     
     - parameter className: The string representation of the class (name of the bundle dot name of the class)
     
     - returns: The Class type
     */
    public class func swiftClassFromString(className: String) -> NSObject? {
        return (swiftClassTypeFromString(className) as? NSObject.Type)?.init()
    }
    
    /**
     Get the class name as a string from a swift class
     
     - parameter theObject: An object for whitch the string representation of the class will be returned
     
     - returns: The string representation of the class (name of the bundle dot name of the class)
     */
    public class func swiftStringFromClass(theObject: NSObject) -> String! {
        return NSStringFromClass(theObject.dynamicType).stringByReplacingOccurrencesOfString(getCleanAppName(theObject) + ".", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    }
    
    /**
     Helper function to convert an Any to AnyObject
     
     - parameter parentObject: Only needs to be set to the object that has this property when the value is from a property that is an array of optional values
     - parameter key:          Only needs to be set to the name of the property when the value is from a property that is an array of optional values
     - parameter anyValue:     Something of type Any is converted to a type NSObject
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The value where the Any is converted to AnyObject plus the type of that value as a string
     */
    public class func valueForAny(parentObject: Any? = nil, key: String? = nil, anyValue: Any, conversionOptions: ConversionOptions = .DefaultDeserialize, isCachable: Bool = false, parents: [NSObject] = []) -> (value: AnyObject, type: String, isObject: Bool) {
        var theValue = anyValue
        var valueType = "EVObject"
        var mi: Mirror = Mirror(reflecting: theValue)
        
        if mi.displayStyle == .Optional {
            if mi.children.count == 1 {
                theValue = mi.children.first!.value
                mi = Mirror(reflecting: theValue)
                if "\(theValue.dynamicType)".hasPrefix("_TtC") {
                  valueType = "\(theValue)".componentsSeparatedByString(" ")[0]
                } else {
                    valueType = "\(theValue.dynamicType)"
                }
            } else if mi.children.count == 0 {
                var subtype: String = "\(mi)"
                subtype = subtype.substringFromIndex((subtype.componentsSeparatedByString("<") [0] + "<").endIndex)
                subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
                return (NSNull(), subtype, false)
            }
        }
        
        if mi.displayStyle == .Enum {
            valueType = "\(theValue.dynamicType)"
            if let value = theValue as? EVRawString {
                return (value.rawValue, "\(mi.subjectType)", false)
            } else if let value = theValue as? EVRawInt {
                return (NSNumber(int: Int32(value.rawValue)), "\(mi.subjectType)", false)
            } else  if let value = theValue as? EVRaw {
                theValue = value.anyRawValue
            } else if let value = theValue as? EVAssociated {
                let (enumValue, enumType, _) = valueForAny(theValue, key: value.associated.label, anyValue: value.associated.value, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                valueType = enumType
                theValue = enumValue
            } else {
                theValue = "\(theValue)"
            }
        } else if mi.displayStyle == .Collection {
            valueType = "\(mi.subjectType)"
            if valueType.hasPrefix("Array<Optional<") {
                if let arrayConverter = parentObject as? EVArrayConvertable {
                    let convertedValue = arrayConverter.convertArray(key!, array: theValue)
                    return (convertedValue, valueType, false)
                }
                (parentObject as? EVObject)?.addStatusMessage(.MissingProtocol, message: "An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key)")
                print("WARNING: An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key)")
                return (NSNull(), "NSNull", false)
            }
        } else if mi.displayStyle == .Dictionary {
            valueType = "\(mi.subjectType)"
            if let dictionaryConverter = parentObject as? EVObject {
                let convertedValue = dictionaryConverter.convertDictionary(key!, dict: theValue)
                return (convertedValue, valueType, false)
            }
        } else if mi.displayStyle == .Set {
            valueType = "\(mi.subjectType)"
            if valueType.hasPrefix("Set<") {
                if let arrayConverter = parentObject as? EVArrayConvertable {
                    let convertedValue = arrayConverter.convertArray(key!, array: theValue)
                    return (convertedValue, valueType, false)
                }
                (parentObject as? EVObject)?.addStatusMessage(.MissingProtocol, message: "An object with a property of type Set should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key)")
                print("WARNING: An object with a property of type Set should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key)")
                return (NSNull(), "NSNull", false)
            }
        } else if mi.displayStyle == .Struct {
            valueType = "\(mi.subjectType)"
            if valueType.containsString("_NativeDictionaryStorage") {
                if let dictionaryConverter = parentObject as? EVObject {
                    let convertedValue = dictionaryConverter.convertDictionary(key!, dict: theValue)
                    return (convertedValue, valueType, false)
                }
            }
            let structAsDict = convertStructureToDictionary(theValue, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
            return (structAsDict, "Struct", false)
        } else {
            valueType = "\(mi.subjectType)"
        }
        
        return valueForAnyDetail(parentObject, key: key, theValue: theValue, valueType: valueType)
    }
    
    public class func valueForAnyDetail(parentObject: Any? = nil, key: String? = nil, theValue: Any, valueType: String) -> (value: AnyObject, type: String, isObject: Bool) {
        
        if theValue is NSNumber {
            return (theValue as! NSNumber, "NSNumber", false)
        }
        if theValue is Int64 {
            return (NSNumber(longLong: theValue as! Int64), "NSNumber", false)
        }
        if theValue is UInt64 {
            return (NSNumber(unsignedLongLong: theValue as! UInt64), "NSNumber", false)
        }
        if theValue is Int32 {
            return (NSNumber(int: theValue as! Int32), "NSNumber", false)
        }
        if theValue is UInt32 {
            return (NSNumber(unsignedInt: theValue as! UInt32), "NSNumber", false)
        }
        if theValue is Int16 {
            return (NSNumber(short: theValue as! Int16), "NSNumber", false)
        }
        if theValue is UInt16 {
            return (NSNumber(unsignedShort: theValue as! UInt16), "NSNumber", false)
        }
        if theValue is Int8 {
            return (NSNumber(char: theValue as! Int8), "NSNumber", false)
        }
        if theValue is UInt8 {
            return (NSNumber(unsignedChar: theValue as! UInt8), "NSNumber", false)
        }
        if theValue is NSString {
            return (theValue as! NSString, "NSString", false)
        }
        if theValue is NSDate {
            return (theValue as! NSDate, "NSDate", false)
        }
        if theValue is NSArray {
            return (theValue as! NSArray, valueType, false)
        }
        if theValue is EVObject {
            if valueType.containsString("<") {
                return (theValue as! EVObject, swiftStringFromClass(theValue as! EVObject), true)
            }
            return (theValue as! EVObject, valueType, true)
        }
        if theValue is NSObject {
            if valueType.containsString("<") {
                return (theValue as! NSObject, swiftStringFromClass(theValue as! NSObject), true)
            }
            // isObject is false to prevent parsing of objects like CKRecord, CKRecordId and other objects.
            return (theValue as! NSObject, valueType, false)
        }
        if valueType.hasPrefix("Array<") && parentObject is EVArrayConvertable {
            return ((parentObject as! EVArrayConvertable).convertArray(key ?? "_unknownKey", array: theValue), valueType, false)
        }
        
        (parentObject as? EVObject)?.addStatusMessage(.InvalidType, message: "valueForAny unkown type \(valueType) for value: \(theValue).")
        print("ERROR: valueForAny unkown type \(valueType) for value: \(theValue).")
        return (NSNull(), "NSNull", false)
    }
    
    private static func convertStructureToDictionary(theValue: Any, conversionOptions: ConversionOptions, isCachable: Bool, parents: [NSObject] = []) -> NSDictionary {
        let reflected = Mirror(reflecting: theValue)
        let (addProperties, _) = reflectedSub(theValue, reflected: reflected, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
        return addProperties
    }

    
    /**
     Try to set a value of a property with automatic String to and from Number conversion
     
     - parameter anyObject:    the object where the value will be set
     - parameter key:          the name of the property
     - parameter theValue:        the value that will be set
     - parameter typeInObject: the type of the value
     - parameter valid: False if a vaue is expected and a dictionary 
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public static func setObjectValue<T where T: NSObject>(anyObject: T, key: String, theValue: AnyObject?, typeInObject: String? = nil, valid: Bool, conversionOptions: ConversionOptions = .DefaultDeserialize, parents: [NSObject] = []) {
        
        guard var value = theValue where (value as? NSNull) == nil else {
            return
        }
        
        if conversionOptions.contains(.PropertyConverter) {
            if let (_, propertySetter, _) = (anyObject as? EVObject)?.propertyConverters().filter({$0.0 == key}).first {
                guard let propertySetter = propertySetter else {
                    return  // if the propertySetter is nil, skip setting the property
                }
                propertySetter(value)
                return
            }
        }
        // Let us put a number into a string property by taking it's stringValue
        let (_, type, _) = valueForAny("", key: key, anyValue: value, conversionOptions: conversionOptions, isCachable: false, parents: parents)
        if (typeInObject == "String" || typeInObject == "NSString") && type == "NSNumber" {
            if let convertedValue = value as? NSNumber {
                value = convertedValue.stringValue
            }
        } else if typeInObject == "NSNumber" && (type == "String" || type == "NSString") {
            if let convertedValue = (value as? String)?.lowercaseString {
                if convertedValue == "true" || convertedValue == "yes" {
                    value = 1
                } else if convertedValue == "false" || convertedValue == "no" {
                    value = 0
                } else {
                    value = NSNumber(double: Double(convertedValue) ?? 0)
                }
            }
        } else if typeInObject == "NSDate"  && (type == "String" || type == "NSString") {
            if let convertedValue = value as? String {
                
                guard let date = getDateFormatter().dateFromString(convertedValue) else {
                    (anyObject as? EVObject)?.addStatusMessage(.InvalidValue, message: "The dateformatter returend nil for value \(convertedValue)")
                    print("WARNING: The dateformatter returend nil for value \(convertedValue)")
                    return
                }
                
                value = date
            }
        }
        if typeInObject == "Struct" {
            anyObject.setValue(value, forUndefinedKey: key)
        } else {
            if !valid {
                anyObject.setValue(theValue, forUndefinedKey: key)
                return
            }
            
            // Call your own object validators that comply to the format: validate<Key>:Error:
            do {
                var setValue: AnyObject? = value
                try anyObject.validateValue(&setValue, forKey: key)
                anyObject.setValue(setValue, forKey: key)
            } catch _ {
                (anyObject as? EVObject)?.addStatusMessage(.InvalidValue, message: "Not a valid value for object `\(anyObject.dynamicType)`, type `\(type)`, key  `\(key)`, value `\(value)`")
                print("INFO: Not a valid value for object `\(anyObject.dynamicType)`, type `\(type)`, key  `\(key)`, value `\(value)`")
            }
            
            /*  TODO: Do I dare? ... For nullable types like Int? we could use this instead of the workaround.
             // Asign pointerToField based on specific type
             
             // Look up the ivar, and it's offset
             let ivar: Ivar = class_getInstanceVariable(anyObject.dynamicType, key)
             let fieldOffset = ivar_getOffset(ivar)
             
             // Pointer arithmetic to get a pointer to the field
             let pointerToInstance = unsafeAddressOf(anyObject)
             let pointerToField = UnsafeMutablePointer<Int?>(pointerToInstance + fieldOffset)
             
             // Set the value using the pointer
             pointerToField.memory = value!
             */
        }
    }
    
    
    // MARK: - Private helper functions
    
    /**
    Create a dictionary of all property - key mappings
    
    - parameter theObject:  the object for what we want the mapping
    - parameter properties: dictionairy of all the properties
    - parameter types:      dictionairy of all property types.
    
    - returns: dictionairy of the property mappings
    */
    private class func cleanupKeysAndValues(theObject: NSObject, properties: NSDictionary, types: NSDictionary) -> (NSDictionary, NSDictionary) {
        let newProperties = NSMutableDictionary()
        let newTypes = NSMutableDictionary()
        for (key, _) in properties {
            if let newKey = cleanupKey(theObject, key: (key as? String)!, tryMatch: nil) {
                newProperties[newKey] = properties[(key as? String)!]
                newTypes[newKey] = types[(key as? String)!]
            }
        }
        return (newProperties, newTypes)
    }
    

    /**
     Try to map a property name to a json/dictionary key by applying some rules like property mapping, snake case conversion or swift keyword fix.
     
     - parameter anyObject: the object where the key is part of
     - parameter key:       the key to clean up
     - parameter tryMatch:  dictionary of keys where a mach will be tried to
     
     - returns: the cleaned up key
     */
    private class func cleanupKey(anyObject: NSObject, key: String, tryMatch: NSDictionary?) -> String? {
        var newKey: String = key
        
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        // Step 1 - clean up keywords
        if newKey.characters.first == "_" {
            if keywords.contains(newKey.substringFromIndex(newKey.startIndex.advancedBy(1))) {
                newKey = newKey.substringFromIndex(newKey.startIndex.advancedBy(1))
                if tryMatch?[newKey] != nil {
                    return newKey
                }
            }
        }
        
        // Step 2 - replace illegal characters
        if let t = tryMatch {
            for (key, _) in t {
                var k = key
                if let kIsString = k as? String {
                    k = processIllegalCharacters(kIsString)
                }
                if k as? String == newKey {
                    return key as? String
                }
            }
        }
        // Step 3 - from PascalCase or camelCase
        newKey = PascalCaseToCamelCase(newKey)
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        // Step 3 - from camelCase to snakeCase
        newKey = camelCaseToUnderscores(newKey)
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        
        if tryMatch != nil {
            return nil
        }
        
        return newKey
    }
    
    /// Character that will be replaced by _ from the keys in a dictionary / json
    private static let illegalCharacterSet = NSCharacterSet(charactersInString: " -&%#@!$^*()<>?.,:;")
    /// processIllegalCharacters Cache
    private static var processIllegalCharactersCache = [ String : String ]()
    /**
     Replace illegal characters to an underscore
     
     - parameter input: key
     
     - returns: processed string with illegal characters converted to underscores
     */
    internal static func processIllegalCharacters(input: String) -> String {
        
        if let cacheHit = processIllegalCharactersCache[input] {
            return cacheHit
        }
        
        let output = input.componentsSeparatedByCharactersInSet(illegalCharacterSet).joinWithSeparator("_")
        
        processIllegalCharactersCache[input] = output
        return output
    }

    /// camelCaseToUnderscoresCache Cache
    private static var camelCaseToUnderscoresCache = [ String : String ]()
    /**
     Convert a CamelCase to Underscores
     
     - parameter input: the CamelCase string
     
     - returns: the underscore string
     */
    internal static func camelCaseToUnderscores(input: String) -> String {

        if let cacheHit = camelCaseToUnderscoresCache[input] {
            return cacheHit
        }
        
        var output: String = String(input.characters.first!).lowercaseString
        let uppercase: NSCharacterSet = NSCharacterSet.uppercaseLetterCharacterSet()
        for character in input.substringFromIndex(input.startIndex.advancedBy(1)).characters {
            if uppercase.characterIsMember(String(character).utf16.first!) {
                output += "_\(String(character).lowercaseString)"
            } else {
                output += "\(String(character))"
            }
        }
        
        camelCaseToUnderscoresCache[input] = output
        return output
    }

    
    
    /**
     Convert a CamelCase to pascalCase
     
     - parameter input: the CamelCase string
     
     - returns: the pascalCase string
     */
    internal static func PascalCaseToCamelCase(input: String) -> String {
        return String(input.characters.first!).lowercaseString + input.substringFromIndex(input.startIndex.successor())
    }
    
    
    
    /// List of swift keywords for cleaning up keys
    private static let keywords = ["self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public", "internal", "zone"]
    
    /**
     Convert a value in the dictionary to the correct type for the object
     
     - parameter anyObject: The object where this dictionary is a property
     - parameter key: The property name that is the dictionary
     - parameter fieldType:  type of the field in object
     - parameter original:  the original value
     - parameter theDictValue: the value from the dictionary
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The converted value plus a boolean indicating if it's an object
     */
    private static func dictionaryAndArrayConversion(anyObject: NSObject, key: String, fieldType: String?, original: NSObject?, theDictValue: AnyObject?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (AnyObject?, Bool) {
        var dictValue = theDictValue
        var valid = true
        if let type = fieldType {
            if type.hasPrefix("Array<") && dictValue as? NSDictionary != nil {
                if (dictValue as? NSDictionary)?.count == 1 {
                    // XMLDictionary fix
                    let onlyElement = (dictValue as? NSDictionary)?.generate().next()
                    let t: String = (onlyElement?.key as? String) ?? ""
                    if onlyElement?.value as? NSArray != nil && type.lowercaseString == "array<\(t)>" {
                        dictValue = onlyElement?.value as? NSArray
                        dictValue = dictArrayToObjectArray(type, array: (dictValue as? [NSDictionary]) ?? [NSDictionary](), conversionOptions: conversionOptions) as NSArray
                    } else {
                        // Single object array fix
                        var array: [NSDictionary] = [NSDictionary]()
                        array.append(dictValue as? NSDictionary ?? NSDictionary())
                        dictValue = dictArrayToObjectArray(type, array: array, conversionOptions: conversionOptions) as NSArray
                    }
                } else {
                    // Single object array fix
                    var array: [NSDictionary] = [NSDictionary]()
                    array.append(dictValue as? NSDictionary ?? NSDictionary())
                    dictValue = dictArrayToObjectArray(type, array: array, conversionOptions: conversionOptions) as NSArray
                }
            } else if let _ = type.rangeOfString("_NativeDictionaryStorageOwner"), let dict = dictValue as? NSDictionary, let org = anyObject as? EVObject {
                dictValue = org.convertDictionary(key, dict: dict)
            } else if type != "NSDictionary" && dictValue as? NSDictionary != nil {
                let (dict, isValid) = dictToObject(type, original: original, dict: dictValue as? NSDictionary ?? NSDictionary(), conversionOptions: conversionOptions)
                dictValue = dict ?? dictValue
                valid = isValid
            } else if type.rangeOfString("<NSDictionary>") == nil && dictValue as? [NSDictionary] != nil {
                // Array of objects
                dictValue = dictArrayToObjectArray(type, array: dictValue as? [NSDictionary] ?? [NSDictionary](), conversionOptions: conversionOptions) as NSArray
            } else if original is EVObject && dictValue is String {
                // fixing the conversion from XML without properties
                let (dict, isValid) = dictToObject(type, original:original, dict:  ["__text": dictValue as? String ?? ""], conversionOptions: conversionOptions)
                dictValue = dict ?? dictValue
                valid = isValid
            }
        }
        return (dictValue, valid)
    }
    
    /**
     Set sub object properties from a dictionary
     
     - parameter type: The object type that will be created
     - parameter original: The original value in the object which is used to create a return object
     - parameter dict: The dictionary that will be converted to an object
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The object that is created from the dictionary
     */
    private class func dictToObject<T where T:NSObject>(type: String, original: T?, dict: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (T?, Bool) {
        if var returnObject = original {
            if type != "NSNumber" && type != "NSString" && type != "NSDate" && type.containsString("Dictionary<") == false {
                returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject, conversionOptions: conversionOptions)
            } else {
                if type.containsString("Dictionary<") == false {
                    (original as? EVObject)?.addStatusMessage(.InvalidClass, message: "Cannot set values on type \(type) from dictionary \(dict)")
                    print("WARNING: Cannot set values on type \(type) from dictionary \(dict)")
                }
                return (returnObject, false)
            }

            return (returnObject, true)
        }
        
        if var returnObject: NSObject = swiftClassFromString(type) {
            if let evResult = returnObject as? EVObject {
                returnObject = evResult.getSpecificType(dict)
            }
            returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject, conversionOptions: conversionOptions)
            return (returnObject as? T, true)
        }
        
        if type != "Struct" {
            (original as? EVObject)?.addStatusMessage(.InvalidClass, message: "Could not create an instance for type \(type)\ndict:\(dict)")
            print("ERROR: Could not create an instance for type \(type)\ndict:\(dict)")
        }
        return (nil, false)
    }
    
    /**
     Create an Array of objects from an array of dictionaries
     
     - parameter type: The object type that will be created
     - parameter array: The array of dictionaries that will be converted to the array of objects
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The array of objects that is created from the array of dictionaries
     */
    private class func dictArrayToObjectArray(type: String, array: NSArray, conversionOptions: ConversionOptions = .DefaultDeserialize) -> NSArray {
        var subtype = "EVObject"
        if type.componentsSeparatedByString("<").count > 1 {
            // Remove the Array prefix
            subtype = type.substringFromIndex((type.componentsSeparatedByString("<") [0] + "<").endIndex)
            subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
            
            // Remove the optional prefix from the subtype
            if subtype.hasPrefix("Optional<") {
                subtype = subtype.substringFromIndex((subtype.componentsSeparatedByString("<") [0] + "<").endIndex)
                subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
            }
        }
        
        var result = [NSObject]()
        for item in array {
            var org = swiftClassFromString(subtype)
            if let evResult = org as? EVObject {
                org = evResult.getSpecificType(item as? NSDictionary ?? NSDictionary())
            }
            let (arrayObject, valid) = dictToObject(subtype, original:org, dict: item as? NSDictionary ?? NSDictionary(), conversionOptions: conversionOptions)
            if arrayObject != nil && valid {
                result.append(arrayObject!)
            }
        }
        return result
    }
    
    /**
     for parsing an object to a dictionary. including properties from it's super class (recursive)
     
     - parameter theObject: The object as is
     - parameter reflected: The object parsed using the reflect method.
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The dictionary that is created from the object plus an dictionary of property types.
     */
    private class func reflectedSub(theObject: Any, reflected: Mirror, conversionOptions: ConversionOptions = .DefaultDeserialize, isCachable: Bool, parents: [NSObject] = []) -> (NSDictionary, NSDictionary) {
        let propertiesDictionary = NSMutableDictionary()
        let propertiesTypeDictionary = NSMutableDictionary()
        // First add the super class propperties
        if let superReflected = reflected.superclassMirror() {
            let (addProperties, addPropertiesTypes) = reflectedSub(theObject, reflected: superReflected, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
            for (k, v) in addProperties {
                if k as? String != "evReflectionStatuses" {
                    propertiesDictionary.setValue(v, forKey: k as? String ?? "")
                    propertiesTypeDictionary[k as? String ?? ""] = addPropertiesTypes[k as? String ?? ""]
                }
            }
        }
        for property in reflected.children {
            if let originalKey: String = property.label {
                var skipThisKey = false
                var mapKey = originalKey
                if originalKey  == "evReflectionStatuses" {
                    skipThisKey = true
                }
                if conversionOptions.contains(.PropertyMapping) {
                    if let evObject = theObject as? EVObject {
                        if let mapping = evObject.propertyMapping().filter({$0.0 == originalKey}).first {
                            if mapping.1 == nil {
                                skipThisKey = true
                            } else {
                                mapKey = mapping.1!
                            }
                        }
                    }
                }
                if !skipThisKey {
                    var value = property.value
                    
                    // Convert the Any value to a NSObject value
                    var (unboxedValue, valueType, isObject) = valueForAny(theObject, key: originalKey, anyValue: value, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)

                    if conversionOptions.contains(.PropertyConverter) {
                        // If there is a properyConverter, then use the result of that instead.
                        if let (_, _, propertyGetter) = (theObject as? EVObject)?.propertyConverters().filter({$0.0 == originalKey}).first {
                            
                            guard let propertyGetter = propertyGetter else {
                                continue    // if propertyGetter is nil, skip getting the property
                            }
                            
                            value = propertyGetter()
                            
                            let (unboxedValue2, _, _) = valueForAny(theObject, key: originalKey, anyValue: value, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                            unboxedValue = unboxedValue2
                        }
                    }
                    
                    if isObject {
                        // sub objects will be added as a dictionary itself.
                        let (dict, _) = toDictionary(unboxedValue as? NSObject ?? NSObject(), conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                        unboxedValue = dict
                    } else if let array = unboxedValue as? [NSObject] {
                        if unboxedValue as? [String] != nil || unboxedValue as? [NSString] != nil || unboxedValue as? [NSDate] != nil || unboxedValue as? [NSNumber] != nil || unboxedValue as? [NSArray] != nil || unboxedValue as? [NSDictionary] != nil {
                            // Arrays of standard types will just be set
                        } else {
                            // Get the type of the items in the array
                            let item: NSObject
                            if array.count > 0 {
                                item = array[0]
                            } else {
                                item = array.getArrayTypeInstance(array)
                            }
                            let (_, _, isObject) = valueForAny(anyValue: item, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                            if isObject {
                                // If the items are objects, than add a dictionary of each to the array
                                var tempValue = [NSDictionary]()
                                for av in array {
                                    let (dict, _) = toDictionary(av, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                                    tempValue.append(dict)
                                }
                                unboxedValue = tempValue
                            }
                        }
                    }
                    
                    if conversionOptions.contains(.SkipPropertyValue) {
                        if let evObject = theObject as? EVObject {
                            if !evObject.skipPropertyValue(unboxedValue, key: mapKey) {
                                propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                                propertiesTypeDictionary[mapKey] = valueType
                            }
                        } else {
                            propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                            propertiesTypeDictionary[mapKey] = valueType
                        }
                    } else {
                        propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                        propertiesTypeDictionary[mapKey] = valueType
                    }
                }
            }
        }
        return (propertiesDictionary, propertiesTypeDictionary)
    }
    
    
    /**
     Clean up dictionary so that it can be converted to json
     
     - parameter dict: The dictionairy that
     
     - returns: The cleaned up dictionairy
     */
    private class func convertDictionaryForJsonSerialization(dict: NSDictionary, theObject: NSObject) -> NSDictionary {
        let dict2: NSMutableDictionary = NSMutableDictionary()
        for (key, value) in dict {
            dict2.setValue(convertValueForJsonSerialization(value, theObject: theObject), forKey: key as? String ?? "")
        }
        return dict2
    }
    
    /**
     Clean up a value so that it can be converted to json
     
     - parameter value: The value to be converted
     
     - returns: The converted value
     */
    private class func convertValueForJsonSerialization(value: AnyObject, theObject: NSObject) -> AnyObject {
        switch value {
        case let stringValue as NSString:
            return stringValue
        case let numberValue as NSNumber:
            return numberValue
        case let nullValue as NSNull:
            return nullValue
        case let arrayValue as NSArray:
            let tempArray: NSMutableArray = NSMutableArray()
            for value in arrayValue {
                tempArray.addObject(convertValueForJsonSerialization(value, theObject: theObject))
            }
            return tempArray
        case let date as NSDate:
            return (getDateFormatter().stringFromDate(date) ?? "")
        case let ok as NSDictionary:
            return convertDictionaryForJsonSerialization(ok, theObject: theObject)
        default:
            (theObject as? EVObject)?.addStatusMessage(.InvalidType, message: "Unexpected type while converting value for JsonSerialization: \(value)")
            NSLog("ERROR: Unexpected type while converting value for JsonSerialization")
            return "\(value)"
        }
    }
}



/**
 For specifying what conversion options should be executed
 */
public struct ConversionOptions: OptionSetType, CustomStringConvertible {
    /// The numeric representation of the options
    public let rawValue: Int
    /**
     Initialize with a raw value
     
     - parameter rawValue: the numeric representation
     
     - returns: The ConversionOptions
     */
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// No conversion options
    public static let None = ConversionOptions(rawValue: 0)
    /// Execute property converters
    public static let PropertyConverter = ConversionOptions(rawValue: 1)
    /// Execute property mapping
    public static let PropertyMapping = ConversionOptions(rawValue: 2)
    /// Skip specific property values
    public static let SkipPropertyValue = ConversionOptions(rawValue: 4)
    /// Do a key cleanup (CameCase, snake_case)
    public static let KeyCleanup = ConversionOptions(rawValue: 8)
    
    /// Default used for NSCoding
    public static var DefaultNSCoding: ConversionOptions = [None]
    /// Default used for comparing / hashing functions
    public static var DefaultComparing: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue]
    /// Default used for deserialisation
    public static var DefaultDeserialize: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue, KeyCleanup]
    /// Default used for serialisation
    public static var DefaultSerialize: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue]
    
    /// Get a nice description of the ConversionOptions
    public var description: String {
        let strings = ["PropertyConverter", "PropertyMapping", "SkipPropertyValue", "KeyCleanup"]
        var members = [String]()
        for (flag, string) in strings.enumerate() where contains(ConversionOptions(rawValue:1<<(flag + 1))) {
            members.append(string)
        }
        if members.count == 0 {
            members.append("None")
        }
        return members.description
    }

}

/**
 Type of status messages after deserialisation
 */
public struct DeserialisationStatus: OptionSetType, CustomStringConvertible {
    /// The numeric representation of the options
    public let rawValue: Int
    /**
     Initialize with a raw value
     
     - parameter rawValue: the numeric representation
     
     - returns: the DeserialisationStatus
     */
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// No status message
    public static let None = DeserialisationStatus(rawValue: 0)
    /// Incorrect key error
    public static let IncorrectKey  = DeserialisationStatus(rawValue: 1)
    /// Missing key error
    public static let MissingKey  = DeserialisationStatus(rawValue: 2)
    /// Invalid type error
    public static let InvalidType  = DeserialisationStatus(rawValue: 4)
    /// Invalid value error
    public static let InvalidValue  = DeserialisationStatus(rawValue: 8)
    /// Invalid class error
    public static let InvalidClass  = DeserialisationStatus(rawValue: 16)
    /// Missing protocol error
    public static let MissingProtocol  = DeserialisationStatus(rawValue: 32)
    /// Custom status message
    public static let Custom  = DeserialisationStatus(rawValue: 64)
    
    /// Get a nice description of the DeserialisationStatus
    public var description: String {
        let strings = ["IncorrectKey", "MissingKey", "InvalidType", "InvalidValue", "InvalidClass", "MissingProtocol", "Custom"]
        var members = [String]()
        for (flag, string) in strings.enumerate() where contains(DeserialisationStatus(rawValue:1<<(flag))) {
            members.append(string)
        }
        if members.count == 0 {
            members.append("None")
        }
        return members.description
    }
}
