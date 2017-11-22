//
//  RealmOptionalEVReflectable.swift
//
//  Created by Edwin Vermeer on 22/10/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmOptional : EVCustomReflectable {
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     
     - parameter value: The dictionary that will be converted to an object
     */
    public func constructWith(value: Any?) {
        self.value = value.map(dynamicBridgeCast)
    }
    
    /**
     If you have a custom type that requires special conversion, then you can extend it with the EVCustomReflectable protocol.
     Since Mirror does not work for a Realm Object we use the .value forKey
     
     - returns: Dictionary without custom properties key
     */
    public func toCodableValue() -> Any {
        return self.value as Any
    }
    
    // Bridge cast the Any value to the RealmOptional value (function is copy from Realm's Util.swift)
    internal func dynamicBridgeCast<T>(fromObjectiveC x: Any) -> T {
        if T.self == DynamicObject.self {
            return unsafeBitCast(x as AnyObject, to: T.self)
        } else if let BridgeableType = T.self as? CustomObjectiveCBridgeable.Type {
            return BridgeableType.bridging(objCValue: x) as! T
        } else {
            return x as! T
        }
    }
    
}

// Used for conversion from Objective-C types to Swift types
internal protocol CustomObjectiveCBridgeable {
    static func bridging(objCValue: Any) -> Self
    var objCValue: Any { get }
}
