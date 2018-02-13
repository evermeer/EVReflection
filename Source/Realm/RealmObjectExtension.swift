//
//  RealmObjectExtension.swift
//
//  Created by Edwin Vermeer on 20/11/2017.
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
        } else if let current = super.value(forKey: key) {
            if current is NSNumber, value is NSString {
                //If we do have key and the types are different, then this is called from EVReflection
                let num = NSNumber(value: Int("\(value as! NSString)") ?? 0)
                super.setValue(num, forUndefinedKey: key)
            } else if type(of: current) == type(of: value!)
                || (String(describing: type(of: current)).hasPrefix("List<") && value! is NSArray) {
                super.setValue(value, forUndefinedKey: key)
            } else {
                (self as? EVReflectable)?.addStatusMessage(.InvalidType, message: "Invalid type for the key '\(key)' in the class '\(EVReflection.swiftStringFromClass(self))'")
                evPrint(.IncorrectKey, "WARNING: the type (\(type(of: current)) of the The key '\(key)' in class '\(EVReflection.swiftStringFromClass(self))' does not corresponds to the type (\(type(of: value!)) in the json or Realm database.\n")
            }
        } else if objectSchema.properties.first(where: { $0.name == key }) != nil {
            super.setValue(value, forUndefinedKey: key)
        } else {
            (self as? EVReflectable)?.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            evPrint(.IncorrectKey, "WARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n❓ This could be a strange Realm List issue where the key is reported undefined but it's still set.\n")
        }
    }

    // To make sure that we can get a value without crashing
    override open func value(forUndefinedKey key: String) -> Any? {
        if objectSchema.properties.map({$0.name}).contains(key) == true {
            return super.value(forUndefinedKey: key)
        }
        
        return nil
    }
}

