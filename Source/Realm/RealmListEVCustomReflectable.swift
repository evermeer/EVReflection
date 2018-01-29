//
//  RealmListEVReflectable.swift
//
//  Created by Edwin Vermeer on 29/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift

// We have to use custom reflection for a Realm list because Mirror often does not work.
extension List : EVCustomReflectable {
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - parameter value: The dictionary that will be converted to an object
     */
    public func constructWith(value: Any?) -> EVCustomReflectable {
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
        return self
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


