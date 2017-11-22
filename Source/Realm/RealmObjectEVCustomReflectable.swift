//
//  RealmObjectEVReflectable.swift
//
//  Created by Edwin Vermeer on 20/11/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift


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
