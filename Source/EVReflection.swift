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
    public class func fromDictionary(_ dictionary: NSDictionary, anyobjectTypeString: String, conversionOptions: ConversionOptions = .DefaultDeserialize) -> NSObject? {
        if var nsobject = swiftClassFromString(anyobjectTypeString) {
            if let evResult = nsobject as? EVReflectable {
                if let type = evResult.getType(dictionary) as? NSObject {
                    nsobject = type
                }
                if let specific = evResult.getSpecificType(dictionary) as? NSObject {
                    nsobject = specific
                } else if let evResult = nsobject as? EVGenericsKVC {
                    nsobject = evResult.getGenericType()
                }
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
    @discardableResult
    public class func setPropertiesfromDictionary<T>(_ dictionary: NSDictionary, anyObject: T, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) -> T where T: NSObject {
        
        guard let dict = ((forKeyPath == nil) ? dictionary : dictionary.value(forKeyPath: forKeyPath!) as? NSDictionary) else {
            evPrint(.UnknownKeypath, "ERROR: The forKeyPath '\(forKeyPath ?? "")' did not return a dictionary")
            return anyObject
        }
        
        (anyObject as? EVReflectable)?.initValidation(dict)
        let (keyMapping, _, types) = getKeyMapping(anyObject, dictionary: dict, conversionOptions: .None)
        for (k, v) in dict {
            let keyInObject: String? = (keyMapping.first { $0.keyInResource == k as? String })?.keyInObject
            if keyInObject != nil {
                let original: Any? = getValue(anyObject, key: keyInObject!)
                let dictKey: String = cleanupKey(anyObject, key: k as? String ?? "", tryMatch: types) ?? ""
                let valid : Bool
                let dictValue : Any?
                
                if conversionOptions.contains(.PropertyConverter) && (anyObject as? EVReflectable)?.propertyConverters().filter({$0.key == keyInObject}).first != nil {
                    valid = false
                    dictValue = nil
                } else {
                    (dictValue, valid) = dictionaryAndArrayConversion(anyObject, key: keyInObject!, fieldType: types[dictKey] as? String ?? types[keyInObject!] as? String, original: original, theDictValue: v as Any?, conversionOptions: conversionOptions)
                }
                
                if var value: Any = valid ? dictValue : (v as Any) {
                    if let type: String = types[k as! String] as? String {
                        let t: AnyClass? = swiftClassTypeFromString(type)
                        if let c = t as? EVCustomReflectable.Type {
                            if let v = c.constructWith(value: value) {
                                value = v
                            }
                        }
                    }
                    setObjectValue(anyObject, key: keyInObject!, theValue: value, typeInObject: types[keyInObject!] as? String, valid: valid, conversionOptions: conversionOptions)
                }
            }
        }
        return anyObject
    }
    
    public class func getValue(_ fromObject: NSObject, key: String) -> Any? {
        return (Mirror(reflecting: fromObject).children.filter({$0.0 == key}).first)?.value
    }
    
    /**
     Based on an object and a dictionary create a keymapping plus a dictionary of properties plus a dictionary of types
     
     - parameter anyObject:  the object for the mapping
     - parameter dictionary: the dictionary that has to be mapped
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The mapping, keys and values of all properties to items in a dictionary
     */
    fileprivate static func getKeyMapping<T>(_ anyObject: T, dictionary: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (keyMapping: [(keyInObject: String?, keyInResource: String?)], properties: NSDictionary, types: NSDictionary) where T: NSObject {
        let (properties, types) = toDictionary(anyObject, conversionOptions: conversionOptions, isCachable: true)
        var keyMapping: [(keyInObject: String?, keyInResource: String?)] = []
        if let reflectable = anyObject as? EVReflectable {
            keyMapping = reflectable.propertyMapping()
        }
        // Add the mapping from the  keys in the object.
        for (objectKey, _) in properties {
            if (keyMapping.first { $0.keyInObject == objectKey as? String }) == nil {
                if let dictKey = cleanupKey(anyObject, key: objectKey as? String ?? "", tryMatch: dictionary) {
                    keyMapping.append((objectKey as? String, dictKey))
                } else {
                    keyMapping.append((objectKey as? String, objectKey as? String))
                }
            }
        }
        // Also add the unknown mapping, these have to be handled in setValue forUndefinedKey
        for item in dictionary {
            var isAdded = false
            if (keyMapping.first { $0.keyInResource == (item.key as? String ?? "") }) == nil {
                if let reflectable = anyObject as? EVReflectable {
                    if let mapping = reflectable.propertyMapping().filter({$0.keyInResource == item.key as? String}).first {
                        keyMapping.append(mapping)
                        isAdded = true
                    }
                }
                if !isAdded {
                    keyMapping.append((item.key as? String, item.key as? String))
                }
            }
        }
        return (keyMapping, properties, types)
    }
    
    
    fileprivate static let properiesCache = NSCache<NSString, NSDictionary>()
    fileprivate static let typesCache = NSCache<NSString, NSDictionary>()
    
    /**
     Convert an object to a dictionary while cleaning up the keys
     
     - parameter theObject: The object that will be converted to a dictionary
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The dictionary that is created from theObject plus a dictionary of propery types.
     */
    public class func toDictionary(_ theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize, isCachable: Bool = false, parents: [NSObject] = []) -> (NSDictionary, NSDictionary) {
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
        
        var p: NSDictionary = NSDictionary()
        var t: NSDictionary = NSDictionary()
        let key: NSString = "\(swiftStringFromClass(theObject)).\(conversionOptions.rawValue)" as NSString
        if isCachable, let cachedVersionProperty = properiesCache.object(forKey: key), let cachedVersionTypes = typesCache.object(forKey: key) {
            p = cachedVersionProperty
            t = cachedVersionTypes
        } else {
            let reflected = Mirror(reflecting: theObject)
            var (properties, types) =  reflectedSub(theObject, reflected: reflected, conversionOptions: conversionOptions, isCachable: isCachable, parents: theParents)
            if conversionOptions.contains(.KeyCleanup) {
                (properties, types) = cleanupKeysAndValues(theObject, properties:properties, types:types)
            }
            p = properties
            t = types
            if isCachable {
                properiesCache.setObject(p, forKey: key)
                typesCache.setObject(t, forKey: key)
            }
        }
        return (p, t)
    }
    
    
    // MARK: - From and to JSON parsing
    
    /**
    Return a dictionary representation for the json string
    
    - parameter json: The json string that will be converted
    
    - returns: The dictionary representation of the json
    */
    public class func dictionaryFromJson(_ json: String?) -> NSDictionary {
        let result = NSMutableDictionary()
        if json == nil {
            evPrint(.IsInvalidJson, "ERROR: nil is not valid json!")
        } else if let jsonData = json!.data(using: String.Encoding.utf8) {
            do {
                if let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    return jsonDic
                }
            } catch {
                evPrint(.IsInvalidJson, "ERROR: Invalid json! \(error.localizedDescription)")
            }
        }
                
        return result
    }

    /**
     Return an array of dictionaries as the representation for the json string
     
     - parameter json: The json string that will be converted
     
     - returns: The dictionary representation of the json
     */
    public class func dictionaryArrayFromJson(_ json: String?) -> [NSDictionary] {
        let result = [NSDictionary]()
        if json == nil {
            evPrint(.IsInvalidJson, "ERROR: nil is not valid json!")
        } else if let jsonData = json!.data(using: String.Encoding.utf8) {
            do {
                if let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                    return jsonDic
                }
            } catch {
                evPrint(.IsInvalidJson, "ERROR: Invalid json! \(error.localizedDescription)")
            }
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
    public class func arrayFromData<T>(_ theObject: NSObject? = nil, type: T, data: Data?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) -> [T] {
        var result = [T]()
        if data == nil {
            evPrint(.IsInvalidJson, "ERROR: json data is nil!")
            return result
        }

        do {
            var serialized = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
            if serialized is NSDictionary {
                if forKeyPath == nil {
                    evPrint(.IsInvalidJson, "ERROR: The root of the json is an object and not an array. Specify a forKeyPath to get an item as an array")
                    return result
                } else {
                    serialized = (serialized as! NSDictionary).value(forKeyPath: forKeyPath!) as? [NSDictionary] ?? []
                }
            }
            
            if let jsonDic: [Dictionary<String, AnyObject>] = serialized as? [Dictionary<String, AnyObject>] {
                let nsobjectype: NSObject.Type? = T.self as? NSObject.Type
                if nsobjectype == nil {
                    evPrint(.ShouldExtendNSObject, "ERROR: EVReflection can only be used with types with NSObject as it's minimal base type")
                    return result
                }
                result = jsonDic.map({
                    let nsobject: NSObject = nsobjectype!.init()
                    return (setPropertiesfromDictionary($0 as NSDictionary, anyObject: nsobject, conversionOptions: conversionOptions) as? T)!
                })
            }
        } catch {
            evPrint(.IsInvalidJson, "ERROR: Invalid json! \(error.localizedDescription)")
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
    public class func arrayFromJson<T>(type: T, json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) -> [T] {
        let result = [T]()
        if json == nil {
            evPrint(.IsInvalidJson, "ERROR: nil is not valid json!")
            return result
        }
        guard let data = json!.data(using: String.Encoding.utf8) else {
            evPrint(.IsInvalidJson, "ERROR: Could not get Data from json string using utf8 encoding")
            return result
        }
        return arrayFromData(type: type, data: data, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
    }
    
    /**
     Return a Json string representation of this object
     
     - parameter theObject: The object that will be loged
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The string representation of the object
     */
    public class func toJsonString(_ theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false) -> String {
		let data = toJsonData(theObject, conversionOptions: conversionOptions, prettyPrinted: prettyPrinted)
		return String(data: data, encoding: .utf8) ?? ""
    }

    /**
     Return a Json Data representation of this object
     
     - parameter theObject: The object that will be loged
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The Data representation of the object
     */
    public class func toJsonData(_ theObject: NSObject, conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false) -> Data {
        var dict: NSDictionary
        
        // Custom or standard toDictionary
        if let v = theObject as? EVCustomReflectable {
            dict = v.toCodableValue() as? NSDictionary ?? NSDictionary()
        } else {
            let (dictionary, _) = EVReflection.toDictionary(theObject, conversionOptions: conversionOptions)
            dict = dictionary
        }
        
        dict = convertDictionaryForJsonSerialization(dict, theObject: theObject)
        do {
            if prettyPrinted {
                return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            }
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch { }
        return Data()        
    }

    
    
    // MARK: - Adding functionality to objects
    
    /**
    Dump the content of this object to the output
    
    - parameter theObject: The object that will be loged
    */
    public class func logObject(_ theObject: EVReflectable, prettyPrinted: Bool = true) {
        NSLog(description(theObject, prettyPrinted: prettyPrinted))
    }
    
    /**
     Return a string representation of this object
     
     - parameter theObject: The object that will be loged
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The string representation of the object
     */
    public class func description(_ theObject: EVReflectable, conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = true) -> String {
        if let obj = theObject as? NSObject {
            return "\(swiftStringFromClass(obj)) = \(theObject.toJsonString(prettyPrinted: prettyPrinted))"
        }
        evPrint(.ShouldExtendNSObject, "ERROR: \(String(reflecting: theObject)) should have NSObject as it's base type.")
        return "\(String(reflecting: theObject))"
    }

    
    /**
     Create a hashvalue for the object
     
     - parameter theObject: The object for what you want a hashvalue
     
     - returns: the hashvalue for the object
     */
    public class func hashValue(_ theObject: NSObject) -> Int {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: .DefaultComparing)
        return Int(hasKeys.map {$1}.reduce(0) {(31 &* $0) &+ ($1 as AnyObject).hash})
    }
    
    
    /**
     Encode any object
     
     - parameter theObject: The object that we want to encode.
     - parameter aCoder: The NSCoder that will be used for encoding the object.
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public class func encodeWithCoder(_ theObject: NSObject, aCoder: NSCoder, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: conversionOptions)
        for (key, value) in hasKeys {
            aCoder.encode(value, forKey: key as? String ?? "")
        }
    }
    
    /**
     Decode any object
     
     - parameter theObject: The object that we want to decode.
     - parameter aDecoder: The NSCoder that will be used for decoding the object.
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public class func decodeObjectWithCoder(_ theObject: NSObject, aDecoder: NSCoder, conversionOptions: ConversionOptions = .DefaultNSCoding) {
        let (hasKeys, _) = toDictionary(theObject, conversionOptions: conversionOptions, isCachable: true)
        let dict = NSMutableDictionary()
        for (key, _) in hasKeys {
            if aDecoder.containsValue(forKey: (key as? String)!) {
                let newValue: AnyObject? = aDecoder.decodeObject(forKey: (key as? String)!) as AnyObject?
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
    public class func areEqual(_ lhs: NSObject, rhs: NSObject) -> Bool {
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
    public class func dictionariesAreEqual(_ lhsdict: NSDictionary, rhsdict: NSDictionary) -> Bool {
        for (key, value) in rhsdict {
            if let compareTo = lhsdict[(key as? String)!] {
                if let dateCompareTo = compareTo as? Date, let dateValue = value as? Date {
                    let t1 = Int64(dateCompareTo.timeIntervalSince1970)
                    let t2 = Int64(dateValue.timeIntervalSince1970)
                    if t1 != t2 {
                        return false
                    }
                } else if let array = compareTo as? NSArray, let arr = value as? NSArray {
                    if arr.count != array.count {
                        return false
                    }
                    for (index, arrayValue) in array.enumerated() {
                        if arrayValue as? NSDictionary != nil {
                            if !dictionariesAreEqual((arrayValue as? NSDictionary)!, rhsdict: (arr[index] as? NSDictionary)!) {
                                return false
                            }
                        } else {
                            if !(arrayValue as AnyObject).isEqual(arr[index]) {
                                return false
                            }
                        }
                    }
                } else if !(compareTo as AnyObject).isEqual(value) {
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
    public class func getCleanAppName(_ forObject: NSObject? = nil) -> String {
        // if an object was specified, then always use the bundle name of that class
        if forObject != nil {
            return nameForBundle(Bundle(for: type(of: forObject!)))
        }
        
        // If no object was specified but an identifier was set, then use that identifier.
        if EVReflection.bundleIdentifier != nil {
            return EVReflection.bundleIdentifier!
        }
        
        // use the bundle name from the main bundle, if that's not set use the identifier
        return nameForBundle(Bundle.main)
    }

    /**
     Get the app name from the 'Bundle name' and if that's empty, then from the 'Bundle identifier' otherwise we assume it's a EVReflection unit test and use that bundle identifier
     
     - parameter aClass: Pass an AnyClass to this method if you know a class from the bundele where you want the name for.
     
     - returns: A cleaned up name of the app.
     */
    public class func getCleanAppName(_ aClass: AnyClass?) -> String {
        // if an object was specified, then always use the bundle name of that class
        if aClass != nil {
            return nameForBundle(Bundle(for: aClass!))
        }
        
        // If no object was specified but an identifier was set, then use that identifier.
        if EVReflection.bundleIdentifier != nil {
            return EVReflection.bundleIdentifier!
        }
        
        // use the bundle name from the main bundle, if that's not set use the identifier
        return nameForBundle(Bundle.main)
    }

    
    /// Variable that can be set using setBundleIdentifier
    fileprivate static var bundleIdentifier: String? = nil
    
    /// Variable that can be set using setBundleIdentifiers
    fileprivate static var bundleIdentifiers: [String]? = nil
    
    /**
     This method can be used in unit tests to force the bundle where classes can be found
     
     - parameter forClass: The class that will be used to find the appName for in which we can find classes by string.
     */
    public class func setBundleIdentifier(_ forClass: AnyClass) {
        EVReflection.bundleIdentifier = nameForBundle(Bundle(for:forClass))
    }

    /**
     This method can be used in unit tests to force the bundle where classes can be found
     
     - parameter identifier: The identifier that will be used.
     */
    public class func setBundleIdentifier(_ identifier: String) {
        EVReflection.bundleIdentifier = identifier
    }
    
    
    /**
     This method can be used in project where models are split between multiple modules.
     
     - parameter classes: classes that that will be used to find the appName for in which we can find classes by string.
     */
    public class func setBundleIdentifiers(_ classes: Array<AnyClass>) {
        bundleIdentifiers = []
        for aClass in classes {
            bundleIdentifiers?.append(nameForBundle(Bundle(for: aClass)))
        }
    }

    /**
     This method can be used in project where models are split between multiple modules.
     
     - parameter identifiers: The array of identifiers that will be used.
     */
    public class func setBundleIdentifiers(_ identifiers: Array<String>) {
        bundleIdentifiers = []
        for identifier in identifiers {
            bundleIdentifiers?.append(identifier)
        }
    }
    
    fileprivate static func nameForBundle(_ bundle: Bundle) -> String {
        // get the bundle name from what is set in the infoDictionary
        var appName = bundle.infoDictionary?[kCFBundleExecutableKey as String] as? String ?? ""
        
        // If it was not set, then use the bundleIdentifier (which is the same as kCFBundleIdentifierKey)
        if appName == "" {
            appName = bundle.bundleIdentifier ?? ""
            appName = appName.split(whereSeparator: {$0 == "."}).map({ String($0) }).last ?? ""
        }
        
        // First character may not be a number
        if appName.prefix(1) >= "0" && appName.prefix(1) <= "9" {
            appName = "_" + String(appName.dropFirst())
        }
        
        // Clean up special characters
        return appName.components(separatedBy: illegalCharacterSet).joined(separator: "_")
    }

    
    /// This dateformatter will be used when a conversion from string to NSDate is required
    fileprivate static var dateFormatter: DateFormatter? = nil
    
    /**
     This function can be used to force using an alternat dateformatter for converting String to NSDate
     
     - parameter formatter: The new DateFormatter
     */
    public class func setDateFormatter(_ formatter: DateFormatter?) {
        dateFormatter = formatter
    }
    
    /**
     This function is used for getting the dateformatter and defaulting to a standard if it's not set
     
     - returns: The dateformatter
     */
    fileprivate class func getDateFormatter() -> DateFormatter {
        if let formatter = dateFormatter {
            return formatter
        }
        dateFormatter = DateFormatter()
        dateFormatter!.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter!.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter!.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ssZ"
        return dateFormatter!
    }
    
    /**
     Get the swift Class type from a string
     
     - parameter className: The string representation of the class (name of the bundle dot name of the class)
     
     - returns: The Class type
     */
    public class func swiftClassTypeFromString(_ className: String) -> AnyClass? {
        if let c = NSClassFromString(className) {
            return c
        }
        
        // The default did not work. try a combi of appname and classname
        if className.range(of: ".", options: NSString.CompareOptions.caseInsensitive) == nil {
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
    public class func swiftClassFromString(_ className: String) -> NSObject? {
        return (swiftClassTypeFromString(className) as? NSObject.Type)?.init()
    }
    
    /**
     Get the class name as a string from a swift class
     
     - parameter theObject: An object for whitch the string representation of the class will be returned
     
     - returns: The string representation of the class (name of the bundle dot name of the class)
     */
    public class func swiftStringFromClass(_ theObject: NSObject) -> String {
        return NSStringFromClass(type(of: theObject)).replacingOccurrences(of: getCleanAppName(theObject) + ".", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
    }

    /**
     Get the class name as a string from a swift class
     
     - parameter aClass: An AnyClass for whitch the string representation of the class will be returned
     
     - returns: The string representation of the class (name of the bundle dot name of the class)
     */
    public class func swiftStringFromClass(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).replacingOccurrences(of: getCleanAppName(aClass) + ".", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
    }

    
    /**
     Helper function to convert an Any to AnyObject
     
     - parameter parentObject: Only needs to be set to the object that has this property when the value is from a property that is an array of optional values
     - parameter key:          Only needs to be set to the name of the property when the value is from a property that is an array of optional values
     - parameter anyValue:     Something of type Any is converted to a type NSObject
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The value where the Any is converted to AnyObject plus the type of that value as a string
     */
    public class func valueForAny(_ parentObject: Any? = nil, key: String? = nil, anyValue: Any, conversionOptions: ConversionOptions = .DefaultDeserialize, isCachable: Bool = false, parents: [NSObject] = []) -> (value: AnyObject, type: String, isObject: Bool) {
        var theValue = anyValue
        var valueType: String = ""
        
        var mi: Mirror = Mirror(reflecting: theValue)
        
        if mi.displayStyle == .optional {
            if mi.children.count == 1 {
                theValue = mi.children.first!.value
                mi = Mirror(reflecting: theValue)
                valueType = String(reflecting:type(of: theValue))
            } else if mi.children.count == 0 {
                valueType = String(reflecting:type(of: theValue))
                var subtype: String = String(valueType[(valueType.components(separatedBy: "<") [0] + "<").endIndex...])
                subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
                valueType = convertToInternalSwiftRepresentation(type: subtype)
                return (NSNull(), valueType, false)
            }
        }
        if mi.displayStyle == .class {
            valueType = String(reflecting:type(of: theValue))
        } else if mi.displayStyle == .enum {
            valueType = String(reflecting:type(of: theValue))
            if let value = theValue as? EVRaw {
                theValue = value.anyRawValue
            } else if let value = theValue as? EVAssociated {
                //let (enumValue, enumType, _) = valueForAny(theValue, key: value.associated.label, anyValue: value.associated.value as Any, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                valueType = "Array<Any>"
                theValue = value.associated.values
            } else if valueType.hasPrefix("Swift.ImplicitlyUnwrappedOptional<") { // Implicitly Unwrapped Optionals are actually fancy enums
                var subtype: String = String(valueType[(valueType.components(separatedBy: "<") [0] + "<").endIndex...])
                subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
                valueType = convertToInternalSwiftRepresentation(type: subtype)

                if mi.children.count == 0 {
                    return (NSNull(), valueType, false)
                }
                theValue = mi.children.first?.value ?? theValue
                let (val, _, _) =  valueForAnyDetail(parentObject, key: key, theValue: theValue, valueType: valueType)
                return (val, valueType, false)
            } else {
                theValue = "\(theValue)"
            }
        } else if mi.displayStyle == .collection {
            valueType = String(reflecting: type(of:theValue))
            if valueType.hasPrefix("Swift.Array<Swift.Optional<") {
                if let arrayConverter = parentObject as? EVArrayConvertable {
                    let convertedValue = arrayConverter.convertArray(key!, array: theValue)
                    return (convertedValue, valueType, false)
                }
                (parentObject as? EVReflectable)?.addStatusMessage(.MissingProtocol, message: "An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key ?? "")")
                evPrint(.MissingProtocol, "WARNING: An object with a property of type Array with optional objects should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key ?? "")")
                return (NSNull(), "NSNull", false)
            }
        } else if mi.displayStyle == .dictionary {
            valueType = String(reflecting: type(of:theValue))
            if let dictionaryConverter = parentObject as? EVReflectable {
                let convertedValue = dictionaryConverter.convertDictionary(key!, dict: theValue)
                return (convertedValue, valueType, false)
            }
        } else if mi.displayStyle == .set {
            valueType = String(reflecting: type(of:theValue))
            if valueType.hasPrefix("Swift.Set<") {
                if let arrayConverter = parentObject as? EVArrayConvertable {
                    let convertedValue = arrayConverter.convertArray(key!, array: theValue)
                    return (convertedValue, valueType, false)
                }
                (parentObject as? EVReflectable)?.addStatusMessage(.MissingProtocol, message: "An object with a property of type Set should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key ?? "")")
                evPrint(.MissingProtocol, "WARNING: An object with a property of type Set should implement the EVArrayConvertable protocol. type = \(valueType) for key \(key ?? "")")
                return (NSNull(), "NSNull", false)
            }
        } else if mi.displayStyle == .struct {
            valueType = String(reflecting: type(of:theValue))
            if valueType.contains("Dictionary") {
                if let dictionaryConverter = parentObject as? EVReflectable {
                    let convertedValue = dictionaryConverter.convertDictionary(key!, dict: theValue)
                    return (convertedValue, valueType, false)
                }
            } else if valueType == "Foundation.Date" {
                return (theValue as! NSDate, "NSDate", false)
            } else if valueType == "Foundation.Data" {
                return (theValue as! NSData, "NSData", false)
            }
            let structAsDict = convertStructureToDictionary(theValue, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
            return (structAsDict, "Struct", false)
        } else {
            valueType = String(reflecting: type(of:theValue))
        }
        valueType = convertToInternalSwiftRepresentation(type: valueType)
        return valueForAnyDetail(parentObject, key: key, theValue: theValue, valueType: valueType)
    }
    
    public class func convertToInternalSwiftRepresentation(type: String) -> String {
        if type.split(separator: "<").count > 1 {
            // Remove the Array or Set prefix
            let prefix = type.split(separator: "<") [0] + "<"
            var subtype = String(type[prefix.endIndex...])
            subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
            return prefix + convertToInternalSwiftRepresentation(type: subtype) + ">"
        }

        if type.contains(".") {
            var parts = type.components(separatedBy: ".")
            if parts.count == 2 {
                return parts[1]
            }
            let c = String(repeating:"C", count: parts.count - 1)
            var rv = "_Tt\(c)\(parts[0].count)\(parts[0])"
            parts.remove(at: 0)
            for part in parts {
                rv = "\(rv)\(part.count)\(part)"
            }
            return rv
        }
        return type
    }
    
    
    public class func valueForAnyDetail(_ parentObject: Any? = nil, key: String? = nil, theValue: Any, valueType: String) -> (value: AnyObject, type: String, isObject: Bool) {
        
        if theValue is NSNumber {
            return (theValue as! NSNumber, "NSNumber", false)
        }
        if theValue is Int64 {
            return (NSNumber(value: theValue as! Int64), "NSNumber", false)
        }
        if theValue is UInt64 {
            return (NSNumber(value: theValue as! UInt64), "NSNumber", false)
        }
        if theValue is Int32 {
            return (NSNumber(value: theValue as! Int32), "NSNumber", false)
        }
        if theValue is UInt32 {
            return (NSNumber(value: theValue as! UInt32), "NSNumber", false)
        }
        if theValue is Int16 {
            return (NSNumber(value: theValue as! Int16), "NSNumber", false)
        }
        if theValue is UInt16 {
            return (NSNumber(value: theValue as! UInt16), "NSNumber", false)
        }
        if theValue is Int8 {
            return (NSNumber(value: theValue as! Int8), "NSNumber", false)
        }
        if theValue is UInt8 {
            return (NSNumber(value: theValue as! UInt8), "NSNumber", false)
        }
        if theValue is NSString {
            return (theValue as! NSString, "NSString", false)
        }
        if theValue is Date {
            return (theValue as AnyObject, "NSDate", false)
        }
        if theValue is UUID {
            return ((theValue as! UUID).uuidString as AnyObject, "NSString", false)
        }
        if theValue is Array<Any> {
            return (theValue as AnyObject, valueType, false)
        }
        if theValue is EVCustomReflectable {
            let value: AnyObject = (theValue as! EVCustomReflectable).toCodableValue() as AnyObject
            return (value, valueType, false)
        }

        if theValue is EVReflectable && theValue is NSObject {
            if valueType.contains("<") {
                return (theValue as! EVReflectable, swiftStringFromClass(theValue as! NSObject), true)
            }
            return (theValue as! EVReflectable, valueType, true)
        }
        if theValue is NSObject {
            if valueType.contains("<") {
                return (theValue as! NSObject, swiftStringFromClass(theValue as! NSObject), true)
            }
            if valueType != "_SwiftValue" {
                // isObject is false to prevent parsing of objects like CKRecord, CKRecordId and other objects.
                return (theValue as! NSObject, valueType, false)
            }
        }
        if valueType.hasPrefix("Swift.Array<") && parentObject is EVArrayConvertable {
            return ((parentObject as! EVArrayConvertable).convertArray(key ?? "_unknownKey", array: theValue), valueType, false)
        }

        (parentObject as? EVReflectable)?.addStatusMessage(.InvalidType, message: "valueForAny unkown type \(valueType) for value: \(theValue).")
        evPrint(.InvalidType, "ERROR: valueForAny unkown type \(valueType) for key: \(key ?? "") and value: \(theValue).")
        return (NSNull(), "NSNull", false)
    }
    
    fileprivate static func convertStructureToDictionary(_ theValue: Any, conversionOptions: ConversionOptions, isCachable: Bool, parents: [NSObject] = []) -> NSDictionary {
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
    public static func setObjectValue<T>(_ anyObject: T, key: String, theValue: Any?, typeInObject: String? = nil, valid: Bool, conversionOptions: ConversionOptions = .DefaultDeserialize, parents: [NSObject] = []) where T: NSObject {
        
        guard var value = theValue , (value as? NSNull) == nil else {
            return
        }
        
        if conversionOptions.contains(.PropertyConverter) {
            if let (_, propertySetter, _) = (anyObject as? EVReflectable)?.propertyConverters().filter({$0.0 == key}).first {
                propertySetter(value)
                return
            }
        }
        
        if conversionOptions.contains(.Decoding), let ro = anyObject as? EVReflectable {
            if let v = ro.decodePropertyValue(value: value, key: key) {
                value = v
            }
        }
        
        // Let us put a number into a string property by taking it's stringValue
        let (_, type, _) = valueForAny("", key: key, anyValue: value, conversionOptions: conversionOptions, isCachable: false, parents: parents)
        if (typeInObject == "String" || typeInObject == "NSString") && type == "NSNumber" {
            if let convertedValue = value as? NSNumber {
                value = convertedValue.stringValue as AnyObject
            }
        } else if typeInObject == "NSNumber" && (type == "String" || type == "NSString") {
            if let convertedValue = (value as? String)?.lowercased() {
                if convertedValue == "true" || convertedValue == "yes" {
                    value = 1 as AnyObject
                } else if convertedValue == "false" || convertedValue == "no" {
                    value = 0 as AnyObject
                } else {
                    value = NSNumber(value: Double(convertedValue) ?? 0 as Double)
                }
            }
        } else if typeInObject == "UUID"  && (type == "String" || type == "NSString") {
            value = UUID(uuidString: value as? String ?? "") as AnyObject? ?? UUID() as AnyObject
        } else if typeInObject == "NSURL" && (type == "String" || type == "NSString") {
            value = NSURL(string: value as? String ?? "")! as AnyObject
        } else if (typeInObject == "NSDate" || typeInObject == "Date")  && (type == "String" || type == "NSString") {
            if let convertedValue = value as? String {
                if let date = getDateFormatter().date(from: convertedValue) {
                    value = date as AnyObject
                } else if let date = Date(fromDateTimeString: convertedValue) {
                    value = date as AnyObject
                } else {
                    (anyObject as? EVReflectable)?.addStatusMessage(.InvalidValue, message: "The dateformatter returend nil for value \(convertedValue)")
                    evPrint(.InvalidValue, "WARNING: The dateformatter returend nil for value \(convertedValue)")
                    return
                }                
            }
        } else if typeInObject == "AnyObject" {
            
        }
        
        if !(value is NSArray)  && (typeInObject ?? "").contains("Swift.Array") {
            value = NSArray(array: [value])
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
                if !(value is NSNull) {
                    var setValue: AnyObject? = value as AnyObject?
                    let validateFunction = "validate" + key.prefix(1).uppercased() + key.dropFirst() + ":error:"
                    if (anyObject as AnyObject).responds(to: Selector(validateFunction)) {
                        try anyObject.validateValue(&setValue, forKey: key)
                    }
                    anyObject.setValue(setValue, forKey: key)
                }
            } catch _ {
                (anyObject as? EVReflectable)?.addStatusMessage(.InvalidValue, message: "Not a valid value for object `\(NSStringFromClass(Swift.type(of: (anyObject as AnyObject))))`, type `\(type)`, key  `\(key)`, value `\(value)`")
                evPrint(.InvalidValue, "INFO: Not a valid value for object `\(NSStringFromClass(Swift.type(of: (anyObject as AnyObject))))`, type `\(type)`, key  `\(key)`, value `\(value)`")
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
    fileprivate class func cleanupKeysAndValues(_ theObject: NSObject, properties: NSDictionary, types: NSDictionary) -> (NSDictionary, NSDictionary) {
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
    fileprivate class func cleanupKey(_ anyObject: NSObject, key: String, tryMatch: NSDictionary?) -> String? {
        var newKey: String = key
        
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        // Step 1 - clean up keywords
        if newKey.first == "_" {
            if keywords.contains(String(newKey[newKey.index(newKey.startIndex, offsetBy: 1)...])) {
                newKey = String(newKey[newKey.index(newKey.startIndex, offsetBy: 1)...])
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
        
        // Step 3 - from CmelCase or pascalCase
        newKey = CamelCaseToPascalCase(newKey)
        if tryMatch?[newKey] != nil {
            return newKey
        }

        // Step 4 - from PascalCase or camelCase
        newKey = PascalCaseToCamelCase(newKey)
        if tryMatch?[newKey] != nil {
            return newKey
        }
        
        // Step 5 - from camelCase to snakeCase
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
    fileprivate static let illegalCharacterSet = CharacterSet(charactersIn: " -&%#@!$^*()<>?.,:;")
    /// processIllegalCharacters Cache
    fileprivate static var processIllegalCharactersCache = NSCache<NSString, NSString>()

    /**
     Replace illegal characters to an underscore
     
     - parameter input: key
     
     - returns: processed string with illegal characters converted to underscores
     */
    internal static func processIllegalCharacters(_ input: String) -> String {
        var p: NSString = ""
        if let cachedVersion = processIllegalCharactersCache.object(forKey: input as NSString) {
            // use the cached version
            p = cachedVersion
        } else {
            // create it from scratch then store in the cache
            p = input.components(separatedBy: illegalCharacterSet).joined(separator: "_") as NSString
            processIllegalCharactersCache.setObject(p, forKey: input as NSString)
        }
        return p as String
    }

    /// camelCaseToUnderscoresCache Cache
    fileprivate static var camelCaseToUnderscoresCache = NSCache<NSString, NSString>()
    
    /**
     Convert a CamelCase to Underscores
     
     - parameter input: the CamelCase string
     
     - returns: the underscore string
     */
    internal static func camelCaseToUnderscores(_ input: String) -> String {
	if input.count == 0 {
            return input
        }
	    
        var p: NSString = ""
        if let cachedVersion = camelCaseToUnderscoresCache.object(forKey: input as NSString) {
            p = cachedVersion
        } else {
            var output: String = String(input.first!).lowercased()
            let uppercase: CharacterSet = CharacterSet.uppercaseLetters
            for character in input[input.index(input.startIndex, offsetBy: 1)...] {
                if uppercase.contains(UnicodeScalar(String(character).utf16.first!)!) {
                    output += "_\(String(character).lowercased())"
                } else {
                    output += "\(String(character))"
                }
            }
            p = output as NSString
            camelCaseToUnderscoresCache.setObject(p, forKey: input as NSString)
        }
        return p as String
    }

    
    
    /**
     Convert a CamelCase to pascalCase
     
     - parameter input: the CamelCase string
     
     - returns: the pascalCase string
     */
    internal static func PascalCaseToCamelCase(_ input: String) -> String {
        if input.count > 1 {
            return String(describing: input.first!).lowercased() + input[input.index(after: input.startIndex)...]
        }
        return input.lowercased()
    }
    
    
    /**
     Convert a PascalCase to camelCase
     
     - parameter input: the CamelCase string
     
     - returns: the pascalCase string
     */
    internal static func CamelCaseToPascalCase(_ input: String) -> String {
        if input.count > 1 {
            return String(describing: input.first!).uppercased() + input[input.index(after: input.startIndex)...]
        }
        return input.uppercased()
    }
    
    /// List of swift keywords for cleaning up keys
    fileprivate static let keywords = ["self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public", "internal", "zone"]
    
    
    fileprivate static func arrayConversion(_ anyObject: NSObject, key: String, fieldType: String?, original: Any?, theDictValue: Any?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> NSArray {
        //Swift.Array<Swift.Array<Swift.Array<A81>>>
        let dictValue: NSArray? = theDictValue as? NSArray
        if fieldType?.hasPrefix("Swift.Array<Swift.Array<") ?? false && theDictValue is NSArray {
            evPrint(.UseWorkaround, "TODO: You have to implement a workaround for double nested arrays. See https://github.com/evermeer/EVReflection/issues/212")
            for item in dictValue! {
                evPrint(.UseWorkaround, "TODO: Have to convert here... NSArray to \(fieldType ?? "") \(item)")
            }
        }
        return dictValue!
    }
    
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
    fileprivate static func dictionaryAndArrayConversion(_ anyObject: NSObject, key: String, fieldType: String?, original: Any?, theDictValue: Any?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (Any?, Bool) {
        var dictValue = theDictValue
        var valid = true
        if let type = fieldType {
            if type.hasPrefix("Swift.Array<") && dictValue is NSArray {
                dictValue = arrayConversion(anyObject, key: key, fieldType: fieldType, original: original, theDictValue: theDictValue, conversionOptions: conversionOptions)
            }
            if type.hasPrefix("Swift.Array<") && dictValue as? NSDictionary != nil {
                if (dictValue as? NSDictionary)?.count == 1 {
                    // XMLDictionary fix
                    let onlyElement = (dictValue as? NSDictionary)?.makeIterator().next()
                    //let t: String = ((onlyElement?.key as? String) ?? "")
                    if onlyElement?.value as? NSArray != nil && type.hasPrefix("Swift.Array<")  { // && type.lowercased().hasSuffix("\(t)>")
                        dictValue = onlyElement?.value as? NSArray
                        dictValue = dictArrayToObjectArray(anyObject, key: key, type: type, array: (dictValue as? [NSDictionary] as NSArray?) ?? [NSDictionary]() as NSArray, conversionOptions: conversionOptions) as NSArray
                    } else {
                        // Single object array fix
                        var array: [NSDictionary] = [NSDictionary]()
                        array.append(dictValue as? NSDictionary ?? NSDictionary())
                        dictValue = dictArrayToObjectArray(anyObject, key: key, type: type, array: array as NSArray, conversionOptions: conversionOptions) as NSArray
                    }
                } else {
                    // Single object array fix
                    var array: [NSDictionary] = [NSDictionary]()
                    array.append(dictValue as? NSDictionary ?? NSDictionary())
                    dictValue = dictArrayToObjectArray(anyObject, key: key, type: type, array: array as NSArray, conversionOptions: conversionOptions) as NSArray
                }
            } else if let _ = type.range(of: "_NativeDictionaryStorageOwner"), let dict = dictValue as? NSDictionary, let org = anyObject as? EVReflectable {
                dictValue = org.convertDictionary(key, dict: dict)
            } else if type != "NSDictionary" && type != "__NSDictionary0" && type != "AnyObject" && dictValue as? NSDictionary != nil { //TODO this too? && original is NSObject
                let (dict, isValid) = dictToObject(type, original: original as? NSObject, dict: dictValue as? NSDictionary ?? NSDictionary(), conversionOptions: conversionOptions)
                dictValue = dict ?? dictValue
                valid = isValid
            } else if type.range(of: "<NSDictionary>") == nil && type.range(of: "<AnyObject>") == nil && dictValue as? [NSDictionary] != nil {
                // Array of objects
                if !(original is EVCustomReflectable) {
                    dictValue = dictArrayToObjectArray(anyObject, key: key, type: type, array: dictValue as? [NSDictionary] as NSArray? ?? [NSDictionary]() as NSArray, conversionOptions: conversionOptions) as NSArray
                }
            } else if dictValue is String && original is NSObject && original is EVReflectable {
                // fixing the conversion from XML without properties
                let (dict, isValid) = dictToObject(type, original:original as? NSObject, dict:  ["__text": dictValue as? String ?? ""], conversionOptions: conversionOptions)
                dictValue = dict ?? dictValue
                valid = isValid
            } else if !type.hasPrefix("Swift.Array<") && !type.hasPrefix("Swift.Set<") {
                if let array = dictValue as? NSArray {
                    if anyObject is EVCustomReflectable {
                        return (array, true)
                    }
                    if let org = anyObject as? EVReflectable {
                        org.addStatusMessage(.InvalidType, message: "Did not expect an array for \(key). Will use the first item instead.")
                        evPrint(.InvalidType, "WARNING: Did not expect an array for \(key). Will use the first item instead.")
                    }
                    if array.count > 0 {
                        return (array[0] as AnyObject?, true)
                    }
                    return (NSNull(), true)
                }
            }
        } else {
            
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
    fileprivate class func dictToObject<T>(_ type: String, original: T?, dict: NSDictionary, conversionOptions: ConversionOptions = .DefaultDeserialize) -> (T?, Bool) where T: NSObject {
        if var returnObject = original {
            if type != "NSNumber" && type != "NSString" && type != "NSDate" && type != "Struct" && type.contains("Dictionary<") == false {
                returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject, conversionOptions: conversionOptions)
            } else {
                if type.contains("Dictionary<") == false && type != "Struct" {
                    (original as? EVReflectable)?.addStatusMessage(.InvalidClass, message: "Cannot set values on type \(type) from dictionary \(dict)")
                    evPrint(.InvalidClass, "WARNING: Cannot set values on type \(type) from dictionary \(dict)")
                }
                return (returnObject, false)
            }

            return (returnObject, true)
        }
        
        var useType = type
        if type.hasPrefix("Swift.Optional<") {
            var subtype: String = String(type[(type.components(separatedBy: "<") [0] + "<").endIndex...])
            subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
            useType = subtype
        }
        
        if var returnObject: NSObject = swiftClassFromString(useType) {
            if let evResult = returnObject as? EVReflectable {
                if let type = evResult.getType(dict) as? NSObject {
                    returnObject = type
                }
                if let specific = evResult.getSpecificType(dict) as? NSObject {
                    returnObject = specific
                } else if let evResult = returnObject as? EVGenericsKVC {
                    returnObject = evResult.getGenericType()
                }
            }
            returnObject = setPropertiesfromDictionary(dict, anyObject: returnObject, conversionOptions: conversionOptions)
            return (returnObject as? T, true)
        }
        
        if useType != "Struct" {
            (original as? EVReflectable)?.addStatusMessage(.InvalidClass, message: "Could not create an instance for type \(type)\ndict:\(dict)")
            evPrint(.InvalidClass, "ERROR: Could not create an instance for type \(useType)\ndict:\(dict)")
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
    fileprivate class func dictArrayToObjectArray(_ anyObject: NSObject, key: String, type: String, array: NSArray, conversionOptions: ConversionOptions = .DefaultDeserialize) -> NSArray {
        var subtype = ""
        if type.components(separatedBy: "<").count > 1 {
            // Remove the Array prefix
            subtype = String(type[(type.components(separatedBy: "<") [0] + "<").endIndex...])
            subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
            
            // Remove the optional prefix from the subtype
            if subtype.hasPrefix("Optional<") {
                subtype = String(subtype[(subtype.components(separatedBy: "<") [0] + "<").endIndex...])
                subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
            }
        }
        
        var result: [NSObject] = Mirror(reflecting: anyObject).children.filter { $0.label == key }.first?.value as? [NSObject] ?? [NSObject]()
        result.removeAll()
        
        for item in array {
            let org = getTypeFor(anyObject: anyObject, key: key, type: subtype, item: item)
            let (arrayObject, valid) = dictToObject(subtype, original:org, dict: item as? NSDictionary ?? NSDictionary(), conversionOptions: conversionOptions)
            if arrayObject != nil && valid {
                result.append(arrayObject!)
            }
        }
        return result as NSArray
    }
    
    fileprivate class func getTypeFor(anyObject: NSObject, key: String, type: String, item: Any) -> NSObject? {
        var org = swiftClassFromString(type)
        if let evResult = org as? EVReflectable {
            if let type = evResult.getType(item as? NSDictionary ?? NSDictionary()) as? NSObject {
                org = type
            }
            if let specific = evResult.getSpecificType(item as? NSDictionary ?? NSDictionary()) as? NSObject {
                org = specific
            } else if let evResult = anyObject as? EVGenericsKVC {
                org = evResult.getGenericType()
            }
        }
        return org
    }
    
    /**
     for parsing an object to a dictionary. including properties from it's super class (recursive)
     
     - parameter theObject: The object as is
     - parameter reflected: The object parsed using the reflect method.
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The dictionary that is created from the object plus an dictionary of property types.
     */
    fileprivate class func reflectedSub(_ theObject: Any, reflected: Mirror, conversionOptions: ConversionOptions = .DefaultDeserialize, isCachable: Bool, parents: [NSObject] = []) -> (NSDictionary, NSDictionary) {
        let propertiesDictionary = NSMutableDictionary()
        let propertiesTypeDictionary = NSMutableDictionary()
        // First add the super class propperties
        if let superReflected = reflected.superclassMirror {
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
                if mapKey.contains(".") {
                    mapKey = mapKey.components(separatedBy: ".")[0] // remover the .storage for lazy properties
                }
                
                if originalKey  == "evReflectionStatuses" {
                    skipThisKey = true
                }
                
                if conversionOptions.contains(.PropertyMapping) {
                    if let reflectable = theObject as? EVReflectable {
                        if let mapping = reflectable.propertyMapping().filter({$0.keyInObject == originalKey}).first {
                            if mapping.keyInResource == nil {
                                skipThisKey = true
                            } else {
                                mapKey = mapping.keyInResource!
                            }
                        }
                    }
                }
                
                if !skipThisKey {
                    var value = property.value
                    
                    // Convert the Any value to a NSObject value
                    var (unboxedValue, valueType, isObject) = valueForAny(theObject, key: originalKey, anyValue: value, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)

                    if let v = value as? EVCustomReflectable {
                        unboxedValue = v.toCodableValue() as AnyObject
                        valueType = String(describing: type(of: v))
                        isObject = false
                    }

                    if conversionOptions.contains(.Encoding), let ro = theObject as? EVReflectable {
                        unboxedValue = ro.encodePropertyValue(value: unboxedValue, key: originalKey) as AnyObject
                    }

                    if conversionOptions.contains(.PropertyConverter) {
                        // If there is a properyConverter, then use the result of that instead.
                        if let (_, _, propertyGetter) = (theObject as? EVReflectable)?.propertyConverters().filter({$0.0 == originalKey}).first {
                            value = propertyGetter() as Any                            
                            let (unboxedValue2, _, _) = valueForAny(theObject, key: originalKey, anyValue: value, conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                            unboxedValue = unboxedValue2
                        }
                    }
                    
                    if isObject {
                        if let obj = unboxedValue as? EVReflectable {
                            if let json = obj.customConverter() {
                                unboxedValue = json as AnyObject
                            } else {
                                // sub objects will be added as a dictionary itself.
                                let (dict, _) = toDictionary(unboxedValue as? NSObject ?? NSObject(), conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                                unboxedValue = dict                                
                            }
                        } else {
                            // sub objects will be added as a dictionary itself.
                            let (dict, _) = toDictionary(unboxedValue as? NSObject ?? NSObject(), conversionOptions: conversionOptions, isCachable: isCachable, parents: parents)
                            unboxedValue = dict
                        }
                    } else if let array = unboxedValue as? [NSObject] {
						var item: Any
						if array.count > 0 {
							item = array[0]
                            // Workaround for bug https://bugs.swift.org/browse/SR-3083
							if let possibleEnumArray = unboxedValue as? [Any] {
								let possibleEnum = possibleEnumArray[0]
								if type(of: item) != type(of: possibleEnum) {
									item = possibleEnum
									var newArray: [AnyObject] = []
									for anEnum in possibleEnumArray {
										let (value, _, _) = valueForAny(anyValue: anEnum)
										newArray.append(value)
									}
									unboxedValue = newArray as AnyObject
								}
							}
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
                            unboxedValue = tempValue as AnyObject
                        }
                    }
                    
                    if conversionOptions.contains(.SkipPropertyValue) {
                        if let reflectable = theObject as? EVReflectable {
                            if !reflectable.skipPropertyValue(unboxedValue, key: mapKey) {
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
    internal class func convertDictionaryForJsonSerialization(_ dict: NSDictionary, theObject: NSObject) -> NSDictionary {
        let dict2: NSMutableDictionary = NSMutableDictionary()
        for (key, value) in dict {
            dict2.setValue(convertValueForJsonSerialization(value as AnyObject, theObject: theObject), forKey: key as? String ?? "")
        }
        return dict2
    }
    
    /**
     Clean up a value so that it can be converted to json
     
     - parameter value: The value to be converted
     
     - returns: The converted value
     */
    fileprivate class func convertValueForJsonSerialization(_ value: Any, theObject: NSObject) -> AnyObject {
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
                tempArray.add(convertValueForJsonSerialization(value as Any, theObject: theObject))
            }
            return tempArray
        case let date as Date:
            return getDateFormatter().string(from: date) as NSString
        case let reflectable as EVCustomReflectable:
            return convertDictionaryForJsonSerialization(reflectable.toCodableValue() as? NSDictionary ?? NSDictionary(), theObject: theObject)
        case let reflectable as EVReflectable:
            return convertDictionaryForJsonSerialization(reflectable.toDictionary(), theObject: theObject)
        case let ok as NSDictionary:
            return convertDictionaryForJsonSerialization(ok, theObject: theObject)
        case let d as Data:
            return d.base64EncodedString() as AnyObject
        default:
            (theObject as? EVReflectable)?.addStatusMessage(.InvalidType, message: "Unexpected type while converting value for JsonSerialization: \(value)")
            evPrint(.InvalidType, "ERROR: Unexpected type while converting value for JsonSerialization: \(value)")
            return "\(value)" as AnyObject
        }
    }
}

extension Date {
    public init?(fromDateTimeString: String) {
        let pattern = "\\\\?/Date\\((\\d+)(([+-]\\d{2})(\\d{2}))?\\)\\\\?/"
        let regex = try! NSRegularExpression(pattern: pattern)
        let match: NSRange = regex.rangeOfFirstMatch(in: fromDateTimeString, range: NSRange(location: 0, length: fromDateTimeString.utf16.count))
        var dateString: String = ""
        if match.location == NSNotFound {
            dateString = fromDateTimeString
        } else {
            dateString = (fromDateTimeString as NSString).substring(with: match)     // Extract milliseconds
        }
        let substrings = dateString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        guard let timeStamp = (substrings.compactMap { Double($0) }.first) else { return nil }
        self.init(timeIntervalSince1970: timeStamp / 1000.0) // Create Date from timestamp
    }
}


