//
//  RealmListEVReflectable.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 29/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift


extension Object {
    /**
     Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter value: The value that you wanted to set
     - parameter key: The name of the property that you wanted to set
     */
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let kvc = self as? EVGenericsKVC {
            kvc.setGenericValue(value as AnyObject!, forUndefinedKey: key)
        } else {
            (self as? EVReflectable)?.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            evPrint(.IncorrectKey, "WARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n❓ This could be a strange Realm List issue where the key is reported undefined but it's still set.\n")
        }
    }
}

// We have to use custom reflection for a Realm object because Mirror often does not work.
extension Object: EVCustomReflectable {
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - parameter value: The dictionary that will be converted to an object
     */
    public func constructWith(value: Any?) {
        if let jsonDict = value as? NSDictionary {
            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
        }
    }
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     Since Mirror does not work for a Realm Object we use the .value forKey
     
     - returns: Dictionary without custom properties key
     */
    public func toCodableValue() -> Any {
        let dict: NSMutableDictionary = (self as? EVReflectable)?.toDictionary() as? NSMutableDictionary ?? NSMutableDictionary()
        let newDict = NSMutableDictionary()
        
        for (key, _) in dict {
            let property: String = key as? String ?? ""
            guard let value = self.value(forKey:property) else { continue }
            if let detachable = value as? Object {
                newDict.setValue(detachable.toCodableValue(), forKey: property)
            } else if let detachable = value as? List<Object> {
                let result = NSMutableArray()
                detachable.forEach {
                    result.add($0.toCodableValue())
                }
                newDict.setValue(result, forKey: property)
            } else {
                newDict.setValue(value, forKey: property)
            }
        }
        return dict
    }
}

// We have to use custom reflection for a Realm list because Mirror often does not work.
extension List : EVCustomReflectable {
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - parameter value: The dictionary that will be converted to an object
     */
    public func constructWith(value: Any?) {
        if let array = value as? [NSDictionary] {
            self.removeAll()
            for dict in array {
                let className: String = (_rlmArray.objectClassName as String?) ?? ""
                if let element: Element = EVReflection.fromDictionary(dict, anyobjectTypeString: className) as? Element {
                    self.append(element)
                }
            }
        } else if let array = value as? NSArray {
            for item in array {
                if let element: Element = item as? Element {
                    self.append(element)
                }
            }
        }
    }
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     Since Mirror does not work for a Realm Object we use the .value forKey
     
     - returns: Dictionary without custom properties key
     */
    public func toCodableValue() -> Any {
        var q = [NSDictionary]()
        for case let e as Any in self {
            q.append((e as? EVReflectable)?.toDictionary([.PropertyConverter, .KeyCleanup, .PropertyMapping, .DefaultSerialize]) ?? NSDictionary())
        }
        return q
 
        // Why do we need all this code? Should be the same as this. But this crashes.
        //return self.enumerated().map { ($0.element as? EVReflectable)?.toDictionary() ?? NSDictionary() }
    }
}
