//
//  RealmListEVReflectable.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 29/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift

extension List : EVCustomReflectable {
    public func constructWith(value: Any?) {
        if let array = value as? [NSDictionary] {
            self.removeAll()
            for dict in array {
                if let element: T = EVReflection.fromDictionary(dict, anyobjectTypeString: _rlmArray.objectClassName) as? T {
                    self.append(element)
                }
            }
        }
    }
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
