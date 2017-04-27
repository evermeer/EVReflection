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
        let e = self.enumerated()
        let r = e.map { o -> NSDictionary in
            if let b = o as? EVReflectable {
                return b.toDictionary()
            }
            return NSDictionary()
        }
        return r
        // Why do we need all this code? Should be the same as:
        //return self.enumerated().map { ($0.element as? EVReflectable)?.toDictionary() ?? NSDictionary() }
    }
}
