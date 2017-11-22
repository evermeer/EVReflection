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
        } else {
            super.setValue(value, forUndefinedKey: key)
            (self as? EVReflectable)?.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            evPrint(.IncorrectKey, "WARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n❓ This could be a strange Realm List issue where the key is reported undefined but it's still set.\n")
        }
    }
}

