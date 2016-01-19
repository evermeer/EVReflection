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
    
    :parameter: dictionary The dictionary that will be converted to an object
    :parameter: anyobjectTypeString The string representation of the object type that will be created
    
    :returns: The object that is created from the dictionary
    */
    public class func fromDictionary(dictionary:NSDictionary, anyobjectTypeString: String) -> NSObject? {
        if var nsobject = swiftClassFromString(anyobjectTypeString) {
            if let evResult = nsobject as? EVObject {
                nsobject = evResult.getSpecificType(dictionary)
            }
            nsobject = setPropertiesfromDictionary(dictionary, anyObject: nsobject)
            return nsobject
        }
        return nil
    }
    
    
    /**
     Set object properties from a dictionary
     
     :parameter: dictionary The dictionary that will be converted to an object
     :parameter: anyObject The object where the properties will be set
     
     :returns: The object that is created from the dictionary
     */
    public class func setPropertiesfromDictionary<T where T:NSObject>(dictionary:NSDictionary, anyObject: T) -> T {
        var (keyMapping, properties, types) = getKeyMapping(anyObject, dictionary: dictionary)
        for (k, v) in dictionary {
            var skipKey = false
            if let evObject = anyObject as? EVObject {
                if let mapping = evObject.propertyMapping().filter({$0.0 == k as? String}).first {
                    if mapping.1 == nil {
                        skipKey = true
                    }
                }
            }
            if !skipKey {
                let mapping = keyMapping[k as! String]
                var original:NSObject? = nil
                if mapping != nil {
                    original = properties[mapping!] as? NSObject         
                }
                if let dictValue = dictionaryAndArrayConversion(types[mapping ?? k as! String], original: original, dictValue: v) {
                    if let key:String = keyMapping[k as! String] {
                        setObjectValue(anyObject, key: key, value: dictValue, typeInObject: types[key])
                    } else {
                        setObjectValue(anyObject, key: k as! String, value: dictValue, typeInObject: types[k as! String])
                    }
                }
            }
        }
        return anyObject
    }
    
    /**
     Based on an object and a dictionary create a keymapping plus a dictionary of properties plus a dictionary of types
     
     :parameter: anyObject  the object for the mapping
     :parameter: dictionary the dictionary that has to be mapped
     
     :returns: The mapping, keys and values of all properties to items in a dictionary
     */
    private static func getKeyMapping<T where T:NSObject>(anyObject: T, dictionary:NSDictionary) -> (keyMapping: Dictionary<String,String>, properties: NSDictionary, types: Dictionary<String,String>) {
        let (hasKeys, hasValues) = toDictionary(anyObject, performKeyCleanup: false)
        var keyMapping: Dictionary<String,String> = Dictionary<String,String>()
        for (objectKey, _) in hasKeys {

            if let evObject = anyObject as? EVObject {
                if let mapping = evObject.propertyMapping().filter({$0.1 == objectKey as? String}).first {
                    keyMapping[objectKey as! String] = mapping.0
                }
            }            
            
            if let dictKey = cleanupKey(anyObject, key: objectKey as! String, tryMatch: dictionary) {
                if dictKey != objectKey  as? String{
                    keyMapping[dictKey] = objectKey as? String
                }
            }
        }
        return (keyMapping, hasKeys, hasValues)
    }
    
    /**
     Convert an object to a dictionary while cleaning up the keys
     
     :parameter: theObject The object that will be converted to a dictionary
     
     :returns: The dictionary that is created from theObject plus a dictionary of propery types.
     */
    public class func toDictionary(theObject: NSObject, performKeyCleanup:Bool = false) -> (NSDictionary, Dictionary<String,String>) {
        let reflected = Mirror(reflecting: theObject)
        let (properties, types) =  reflectedSub(theObject, reflected: reflected, performKeyCleanup: performKeyCleanup)
        if performKeyCleanup {
            return cleanupKeysAndValues(theObject, properties:properties, types:types)
        }
        return (properties, types)
    }
    
    
    // MARK: - From and to JSON parsing
    
    /**
    Return a dictionary representation for the json string
    
    :parameter: json The json string that will be converted
    
    :returns: The dictionary representation of the json
    */
    public class func dictionaryFromJson(json: String?) -> Dictionary<String, AnyObject> {
        var result = Dictionary<String, AnyObject>()
        if json == nil {
            return result
        }
        if let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                    result = jsonDic
                }
            } catch _ as NSError { }
        }
        return result
    }
    
    /**
     Return an array representation for the json string
     
     :parameter: json The json string that will be converted
     
     :returns: The array of dictionaries representation of the json
     */
    public class func arrayFromJson<T>(type:T, json: String?) -> [T] {
        var result = [T]()
        if json == nil {
            return result
        }
        let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            if let jsonDic: [Dictionary<String, AnyObject>] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? [Dictionary<String, AnyObject>] {
                let nsobjectype : NSObject.Type? = T.self as? NSObject.Type
                if nsobjectype == nil {
                    NSLog("WARNING: EVReflection can only be used with types with NSObject as it's minimal base type")
                    return result
                }
                result = jsonDic.map({
                    let nsobject: NSObject = nsobjectype!.init()
                    return setPropertiesfromDictionary($0, anyObject: nsobject) as! T
                })
            }
        } catch _ as NSError {}
        return result
    }
    
    /**
     Return a Json string representation of this object
     
     :parameter: theObject The object that will be loged
     
     :returns: The string representation of the object
     */
    public class func toJsonString(theObject: NSObject, performKeyCleanup:Bool = true) -> String {
        var (dict,_) = EVReflection.toDictionary(theObject, performKeyCleanup: performKeyCleanup)
        dict = convertDictionaryForJsonSerialization(dict)
        var result: String = ""
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict , options: .PrettyPrinted)
            if let jsonString = NSString(data:jsonData, encoding:NSUTF8StringEncoding) {
                result =  jsonString as String
            }
        } catch { }
        return result
    }
    
    
    // MARK: - Adding functionality to objects
    
    /**
    Dump the content of this object to the output
    
    :parameter :theObject The object that will be loged
    
    :returns: Nothing
    */
    public class func logObject(theObject: NSObject) {
        NSLog(description(theObject))
    }
    
    /**
     Return a string representation of this object
     
     :parameter: theObject The object that will be loged
     
     :returns: The string representation of the object
     */
    public class func description(theObject: NSObject) -> String {
        var description: String = swiftStringFromClass(theObject) + " {\n   hash = \(hashValue(theObject))\n"
        let (hasKeys, _) = toDictionary(theObject, performKeyCleanup:false)
        for (key, value) in hasKeys {
            description = description  + "   key = \(key), value = \(value)\n"
        }
        description = description + "}\n"
        return description
    }
    
    /**
     Create a hashvalue for the object
     
     :parameter: theObject The object for what you want a hashvalue
     
     :returns: the hashvalue for the object
     */
    public class func hashValue(theObject: NSObject) -> Int {
        let (hasKeys, _) = toDictionary(theObject, performKeyCleanup:false)
        return Int(hasKeys.map {$1}.reduce(0) {(31 &* $0) &+ $1.hash})
    }
    
    
    /**
     Encode any object
     
     :parameter: theObject The object that we want to encode.
     :parameter: aCoder The NSCoder that will be used for encoding the object.
     
     :returns: Nothing
     */
    public class func encodeWithCoder(theObject: NSObject, aCoder: NSCoder) {
        let (hasKeys, _) = toDictionary(theObject, performKeyCleanup:false)
        for (key, value) in hasKeys {
            aCoder.encodeObject(value, forKey: key as! String)
        }
    }
    
    /**
     Decode any object
     
     :parameter: theObject The object that we want to decode.
     :parameter: aDecoder The NSCoder that will be used for decoding the object.
     */
    public class func decodeObjectWithCoder(theObject: NSObject, aDecoder: NSCoder) {
        let (hasKeys, _) = toDictionary(theObject, performKeyCleanup:false)
        for (key, _) in hasKeys {
            if aDecoder.containsValueForKey(key as! String) {
                let newValue: AnyObject? = aDecoder.decodeObjectForKey(key as! String)
                if !(newValue is NSNull) {
                    theObject.setValue(newValue, forKey: key as! String)
                }
            }
        }
    }
    
    /**
     Compare all fields of 2 objects
     
     :parameter: lhs The first object for the comparisson
     :parameter: rhs The second object for the comparisson
     
     :returns: true if the objects are the same, otherwise false
     */
    public class func areEqual(lhs: NSObject, rhs: NSObject) -> Bool {
        if swiftStringFromClass(lhs) != swiftStringFromClass(rhs) {
            return false;
        }
        
        let (lhsdict,_) = toDictionary(lhs, performKeyCleanup:false)
        let (rhsdict,_) = toDictionary(rhs, performKeyCleanup:false)
        
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
            if let compareTo = lhsdict[key as! String] {
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
                            if !dictionariesAreEqual(arrayValue as! NSDictionary, rhsdict: arr[index] as! NSDictionary) {
                                return false
                            }
                        } else {
                            if !arrayValue.isEqual(arr[index])  {
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
    
    :param: forObject Pass an object to this method if you know a class from the bundele where you want the name for.
    
    :returns: A cleaned up name of the app.
    */
    public class func getCleanAppName(forObject: NSObject? = nil)-> String {
        var bundle = NSBundle.mainBundle()
        if forObject != nil {
            bundle = NSBundle(forClass: forObject!.dynamicType)
        }
        
        if forObject == nil && EVReflection.bundleIdentifier != nil {
            return EVReflection.bundleIdentifier!
        }
        var appName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
        if appName == "" {
            if bundle.bundleIdentifier == nil {
                bundle = NSBundle(forClass: EVReflection().dynamicType)
            }
            appName = (bundle.bundleIdentifier!).characters.split(isSeparator: {$0 == "."}).map({ String($0) }).last ?? ""
        }
        let cleanAppName = appName
            .stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            .stringByReplacingOccurrencesOfString("-", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return cleanAppName
    }
    
    /// Variable that can be set using setBundleIdentifier
    private static var bundleIdentifier:String? = nil
    
    /**
     This method can be used in unit tests to force the bundle where classes can be found
     
     :param: forClass The class that will be used to find the appName for in which we can find classes by string.
     
     :returns: Nothing
     */
    public class func setBundleIdentifier(forClass: AnyClass) {
        if let bundle:NSBundle = NSBundle(forClass:forClass) {
            let appName = (bundle.infoDictionary![kCFBundleNameKey as String] as! String).characters.split(isSeparator: {$0 == "."}).map({ String($0) }).last ?? ""
            //let appName = (bundle.bundleIdentifier!).characters.split(isSeparator: {$0 == "."}).map({ String($0) }).last ?? ""
            let cleanAppName = appName
                .stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                .stringByReplacingOccurrencesOfString("-", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            EVReflection.bundleIdentifier = cleanAppName
        }
    }
    
    /// This dateformatter will be used when a conversion from string to NSDate is required
    private static var dateFormatter: NSDateFormatter? = nil
    
    /**
     This function can be used to force using an alternat dateformatter for converting String to NSDate
     
     - parameter formatter: The new DateFormatter
     */
    public class func setDateFormatter(formatter: NSDateFormatter) {
        dateFormatter = formatter
    }
    
    /**
     This function is used for getting the dateformatter and defaulting to a standard if it's not set
     
     - returns: The dateformatter
     */    private class func getDateFormatter() -> NSDateFormatter {
        if let formatter = dateFormatter {
            return formatter
        }
        dateFormatter = NSDateFormatter()
        dateFormatter!.dateStyle = .ShortStyle
        dateFormatter!.timeStyle = .LongStyle
        return dateFormatter!
    }
    
    /**
     Get the swift Class type from a string
     
     :parameter: className The string representation of the class (name of the bundle dot name of the class)
     
     :returns: The Class type
     */
    public class func swiftClassTypeFromString(className: String) -> AnyClass! {
        //        if className.hasPrefix("Optional<") {
        //            className = className.substringWithRange(Range<String.Index>(start: className.startIndex.advancedBy(9), end: className.endIndex.advancedBy(-1)))
        //        }
        if className.hasPrefix("_Tt") {
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
     Get the swift Class from a string
     
     :parameter: className The string representation of the class (name of the bundle dot name of the class)
     
     :returns: The Class type
     */
    public class func swiftClassFromString(className: String) -> NSObject? {
        var result: NSObject? = nil
        if className == "NSObject" {
            return NSObject()
        }
        if let anyobjectype : AnyObject.Type = swiftClassTypeFromString(className) {
            if let nsobjectype : NSObject.Type = anyobjectype as? NSObject.Type {
                let nsobject: NSObject = nsobjectype.init()
                result = nsobject
            }
        }
        return result
    }
    
    /**
     Get the class name as a string from a swift class
     
     :parameter: theObject An object for whitch the string representation of the class will be returned
     
     :returns: The string representation of the class (name of the bundle dot name of the class)
     */
    public class func swiftStringFromClass(theObject: NSObject) -> String! {
        let appName = getCleanAppName(theObject)
        let classStringName: String = NSStringFromClass(theObject.dynamicType)
        let classWithoutAppName: String = classStringName.stringByReplacingOccurrencesOfString(appName + ".", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return classWithoutAppName
    }
    
    /**
     Helper function to convert an Any to AnyObject
     
     :parameter: parentObject Only needs to be set to the object that has this property when the value is from a property that is an array of optional values
     :parameter: key          Only needs to be set to the name of the property when the value is from a property that is an array of optional values
     :parameter: anyValue     Something of type Any is converted to a type NSObject
     
     :returns: The value where the Any is converted to AnyObject plus the type of that value as a string
     */
    public class func valueForAny(parentObject:Any? = nil, key:String? = nil, anyValue: Any) -> (value: AnyObject, type: String, isObject: Bool) {
        var theValue = anyValue
        var valueType = "EVObject"
        let mi: Mirror = Mirror(reflecting: theValue)
        
        if mi.displayStyle == .Optional {
            if mi.children.count == 1 {
                theValue = mi.children.first!.value
                valueType = "\(mi.children.first!.value.dynamicType)"
            } else if mi.children.count == 0 {
                var subtype: String = "\(mi)"
                subtype = subtype.substringFromIndex((subtype.componentsSeparatedByString("<") [0] + "<").endIndex)
                subtype = subtype.substringToIndex(subtype.endIndex.predecessor())
                return (NSNull(), subtype, false)
            }
        } else if mi.displayStyle == .Enum {
            valueType = "\(theValue.dynamicType)"
            if let value = theValue as? EVRawString {
                return (value.rawValue, "\(mi.subjectType)", false)
            } else if let value = theValue as? EVRawInt {
                return (NSNumber(int: Int32(value.rawValue)), "\(mi.subjectType)", false)
            } else  if let value = theValue as? EVRaw {
                theValue = value.anyRawValue
            } else if let value = theValue as? EVAssociated {
                let (enumValue, enumType, _) = valueForAny(theValue, key: value.associated.label, anyValue: value.associated.value)
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
                assert(true, "WARNING: An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol.")
            }
        }
        else {
            valueType = "\(mi.subjectType)"
        }
        
        switch(theValue) {
            // Bool, Int, UInt, Float and Double are casted to NSNumber by default!
        case let numValue as NSNumber:
            return (numValue, "NSNumber", false)
        case let longValue as Int64:
            return (NSNumber(longLong: longValue), "NSNumber", false)
        case let longValue as UInt64:
            return (NSNumber(unsignedLongLong: longValue), "NSNumber", false)
        case let intValue as Int32:
            return (NSNumber(int: intValue), "NSNumber", false)
        case let intValue as UInt32:
            return (NSNumber(unsignedInt: intValue), "NSNumber", false)
        case let intValue as Int16:
            return (NSNumber(short: intValue), "NSNumber", false)
        case let intValue as UInt16:
            return (NSNumber(unsignedShort: intValue), "NSNumber", false)
        case let intValue as Int8:
            return (NSNumber(char: intValue), "NSNumber", false)
        case let intValue as UInt8:
            return (NSNumber(unsignedChar: intValue), "NSNumber", false)
        case let stringValue as String:
            return (stringValue as NSString, "NSString", false)
        case let dateValue as NSDate:
            return (dateValue, "NSDate", false)
        case let anyvalue as NSArray:
            return (anyvalue, valueType, false)
        case let anyvalue as EVObject:
            if valueType.containsString("<") {
                valueType = swiftStringFromClass(anyvalue)
            }
            return (anyvalue, valueType, true)
        case let anyvalue as NSObject:
            if valueType.containsString("<") {
                valueType = swiftStringFromClass(anyvalue)
            }
            // isObject is false to prevent parsing of objects like CKRecord, CKRecordId and other objects.
            return (anyvalue, valueType, false)
        default:
            NSLog("ERROR: valueForAny unkown type \(theValue), type \(valueType). Could not happen unless there will be a new type in Swift.")
            return (NSNull(), "NSNull", false)
        }
    }
    
    /**
     Try to set a value of a property with automatic String to and from Number conversion
     
     :parameter: anyObject    the object where the value will be set
     :parameter: key          the name of the property
     :parameter: value        the value that will be set
     :parameter: typeInObject the type of the value
     
     :returns: Nothing
     */
    public static func setObjectValue<T where T:NSObject>(anyObject: T, key:String, var value:AnyObject?, typeInObject:String? = nil) {
        if value == nil || value as? NSNull != nil {
            //            do {
            //                var nilValue: AnyObject? = Optional.None
            //                try anyObject.validateValue(&nilValue, forKey: key)
            //                anyObject.setValue(nilValue, forKey: key)
            //            } catch _ {
            //            }
        } else {
            // Let us put a number into a string property by taking it's stringValue
            let (_, type, _) = valueForAny("", key: key, anyValue: value)
            if (typeInObject == "String" || typeInObject == "NSString") && type == "NSNumber" {
                if let convertedValue = value as? NSNumber {
                    value = convertedValue.stringValue
                }
            } else if typeInObject == "NSNumber" && (type == "String" || type == "NSString") {
                if let convertedValue = value as? String {
                    value = NSNumber(double: Double(convertedValue) ?? 0)
                }
            } else if typeInObject == "NSDate"  && (type == "String" || type == "NSString") {
                if let convertedValue = value as? String {
                    value = getDateFormatter().dateFromString(convertedValue)
                }
            }
            if let (_, propertySetter, _) = (anyObject as? EVObject)?.propertyConverters().filter({$0.0 == key}).first {
                propertySetter(value)
                return
            }
            
            if value != nil {
                anyObject.setValue(value!, forKey: key)
            }
            else {
                NSLog("ERROR: cannot map value to key: %@", key)
            }
        }
    }
    
    
    // MARK: - Private helper functions
    
    /**
    Create a dictionary of all property - key mappings
    
    :parameter: theObject  the object for what we want the mapping
    :parameter: properties dictionairy of all the properties
    :parameter: types      dictionairy of all property types.
    
    :returns: dictionairy of the property mappings
    */
    private class func cleanupKeysAndValues(theObject: NSObject, properties:NSDictionary, types:Dictionary<String,String>) -> (NSDictionary, Dictionary<String,String>) {
        let newProperties = NSMutableDictionary()
        var newTypes = Dictionary<String,String>()
        for (key, _) in properties {
            if let newKey = cleanupKey(theObject, key: key as! String, tryMatch: nil) {
                //TODO: cleanup sub objects
                //                if properties[key as! String].dynamicType != Dictionary.type && types[key as! String] == "Dictionary" {
                //
                //                }
                newProperties[newKey] = properties[key as! String]
                newTypes[newKey] = types[key as! String]
            }
        }
        return (newProperties, newTypes)
    }
    
    /**
     Try to map a property name to a json/dictionary key by applying some rules like property mapping, snake case conversion or swift keyword fix.
     
     :parameter: anyObject the object where the key is part of
     :parameter: key       the key to clean up
     :parameter: tryMatch  dictionary of keys where a mach will be tried to
     
     :returns: the cleaned up key
     */
    private class func cleanupKey(anyObject:NSObject, key:String, tryMatch:NSDictionary?) -> String? {
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
                for ic in illegalCharacter {
                    k = k.stringByReplacingOccurrencesOfString(ic, withString: "_")
                }
                if k as! String == newKey {
                    return key as? String
                }
            }
        }
        
        // Step 3 - from PascalCase or camelCase to snakeCase
        newKey = camelCaseToUnderscores(newKey)
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        
        if tryMatch != nil {
            return nil
        }
        
        return newKey
    }
    
    /**
     Convert a CamelCase to Undersores
     
     :parameter: input the CamelCase string
     
     :returns: the underscore string
     */
    internal static func camelCaseToUnderscores(input: String) -> String {
        var output: String = String(input.characters.first!).lowercaseString
        let uppercase:NSCharacterSet = NSCharacterSet.uppercaseLetterCharacterSet()
        for character in input.substringFromIndex(input.startIndex.advancedBy(1)).characters {
            if uppercase.characterIsMember(String(character).utf16.first!) {
                output += "_\(String(character).lowercaseString)"
            } else {
                output += "\(String(character))"
            }
        }
        return output
    }
    
    
    /// List of swift keywords for cleaning up keys
    private static let keywords = ["self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public", "internal", "zone"]
    
    /// Character that will be replaced by _ from the keys in a dictionary / json
    private static let illegalCharacter = [" ", "-", "&", "%", "#", "@", "!", "$", "^", "*", "(", ")", "<", ">", "?", ".", ",", ":", ";"]
    
    /**
     Convert a value in the dictionary to the correct type for the object
     
     :parameter: fieldType  type of the field in object
     :parameter: original  the original value
     :parameter: dictValue the value from the dictionary
     
     :returns: The converted value
     */
    private static func dictionaryAndArrayConversion(fieldType:String?, original:NSObject?, var dictValue: AnyObject?) -> AnyObject? {
        if let type = fieldType {
            if type.hasPrefix("Array<") && dictValue as? NSDictionary != nil {
                if (dictValue as! NSDictionary).count == 1 {
                    // XMLDictionary fix
                    if let i = (dictValue as! NSDictionary).generate().next()!.value as? NSArray {
                        dictValue = i
                        dictValue = dictArrayToObjectArray(type, array: dictValue as! [NSDictionary]) as [NSObject]
                    }
                } else {
                    // Single object array fix
                    var array:[NSDictionary] = [NSDictionary]()
                    array.append(dictValue as! NSDictionary)
                    dictValue = array
                }
            } else if type != "NSDictionary" && dictValue as? NSDictionary != nil {
                // Sub object
                dictValue = dictToObject(type, original:original ,dict: dictValue as! NSDictionary)
            } else if type.rangeOfString("<NSDictionary>") == nil && dictValue as? [NSDictionary] != nil {
                // Array of objects
                dictValue = dictArrayToObjectArray(type, array: dictValue as! [NSDictionary]) as [NSObject]
            }
        }
        return dictValue
    }
    
    /**
     Set sub object properties from a dictionary
     
     :parameter: type The object type that will be created
     :parameter: original The original value in the object which is used to create a return object
     :parameter: dict The dictionary that will be converted to an object
     
     :returns: The object that is created from the dictionary
     */
    private class func dictToObject<T where T:NSObject>(type:String, original:T? ,dict:NSDictionary) -> T? {
        if var returnObject:NSObject = swiftClassFromString(type) {
            if let evResult = returnObject as? EVObject {
                returnObject = evResult.getSpecificType(dict)
            }
            returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject)
            return returnObject as? T
        }
        return nil
    }
    
    /**
     Create an Array of objects from an array of dictionaries
     
     :parameter: type The object type that will be created
     :parameter: array The array of dictionaries that will be converted to the array of objects
     
     :returns: The array of objects that is created from the array of dictionaries
     */
    private class func dictArrayToObjectArray(type:String, array:[NSDictionary]) -> [NSObject] {
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
                org = evResult.getSpecificType(item)
            }
            if let arrayObject = self.dictToObject(subtype, original:org, dict: item) {
                result.append(arrayObject)
            }
        }
        return result
    }
    
    /**
     for parsing an object to a dictionary. including properties from it's super class (recursive)
     
     :parameter: reflected The object parsed using the reflect method.
     
     :returns: The dictionary that is created from the object plus an dictionary of property types.
     */
    private class func reflectedSub(theObject:Any, reflected: Mirror, performKeyCleanup:Bool = false) -> (NSDictionary, Dictionary<String, String>) {
        let propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        var propertiesTypeDictionary : Dictionary<String,String> = Dictionary<String,String>()
        // First add the super class propperties
        if let superReflected = reflected.superclassMirror() {
            let (addProperties, addPropertiesTypes) = reflectedSub(theObject, reflected: superReflected, performKeyCleanup: performKeyCleanup)
            for (k, v) in addProperties {
                propertiesDictionary.setValue(v, forKey: k as! String)
                propertiesTypeDictionary[k as! String] = addPropertiesTypes[k as! String]
            }
        }
        for property in reflected.children {
            if let originalKey:String = property.label {
                var skipThisKey = false
                var mapKey = originalKey
                if let evObject = theObject as? EVObject {
                    if let mapping = evObject.propertyMapping().filter({$0.0 == originalKey}).first {
                        if mapping.1 == nil {
                            skipThisKey = true
                        } else {
                            mapKey = mapping.1!
                        }
                    }
                }
                if !skipThisKey {
                    var value = property.value
                    // If there is a properyConverter, then use the result of that instead.
                    if let (_, _, propertyGetter) = (theObject as? EVObject)?.propertyConverters().filter({$0.0 == originalKey}).first {
                        value = propertyGetter()
                    }
                    // Convert the Any value to a NSObject value
                    var (unboxedValue, valueType, isObject) = valueForAny(theObject, key: originalKey, anyValue: value)
                    if isObject {
                        // sub objects will be added as a dictionary itself.
                        let (dict, _) = toDictionary(unboxedValue as! NSObject, performKeyCleanup: performKeyCleanup)
                        propertiesDictionary.setValue(dict, forKey: mapKey)
                    } else if let array = unboxedValue as? [NSObject] {
                        if unboxedValue as? [String] != nil || unboxedValue as? [NSString] != nil || unboxedValue as? [NSDate] != nil || unboxedValue as? [NSNumber] != nil || unboxedValue as? [NSArray] != nil || unboxedValue as? [NSDictionary] != nil {
                            // Arrays of standard types will just be set
                            propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                        } else {
                            // Get the type of the items in the array
                            let item: NSObject
                            if array.count > 0 {
                                item = array[0]
                            } else {
                                item = array.getArrayTypeInstance(array)
                            }
                            let (_,_,isObject) = valueForAny(anyValue: item)
                            if isObject {
                                // If the items are objects, than add a dictionary of each to the array
                                var tempValue = [NSDictionary]()
                                for av in array {
                                    let (dict, _) = toDictionary(av, performKeyCleanup: performKeyCleanup)
                                    tempValue.append(dict)
                                }
                                unboxedValue = tempValue
                                propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                            } else {
                                propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                            }
                        }
                    } else {
                        propertiesDictionary.setValue(unboxedValue, forKey: mapKey)
                    }
                    
                    propertiesTypeDictionary[mapKey] = valueType
                }
            }
        }
        return (propertiesDictionary, propertiesTypeDictionary)
    }
    
    
    /**
     Clean up dictionary so that it can be converted to json
     
     :parameter: dict The dictionairy that
     
     :returns: The cleaned up dictionairy
     */
    private class func convertDictionaryForJsonSerialization(dict: NSDictionary) -> NSDictionary {
        for (key, value) in dict {
            dict.setValue(convertValueForJsonSerialization(value), forKey: key as! String)
        }
        return dict
    }
    
    /**
     Clean up a value so that it can be converted to json
     
     :parameter: value The value to be converted
     
     :returns: The converted value
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
            let tempArray: NSMutableArray = NSMutableArray()
            for value in arrayValue {
                tempArray.addObject(convertValueForJsonSerialization(value))
            }
            return tempArray
        case let date as NSDate:
            return (getDateFormatter().stringFromDate(date) ?? "")
        case let ok as NSDictionary:
            return convertDictionaryForJsonSerialization(ok)
        default:
            NSLog("ERROR: Unexpected type while converting value for JsonSerialization")
            return "\(value)"
        }
    }
}


