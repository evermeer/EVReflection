//
//  EVCustomReflectable.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 27/10/2016.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation

// Protocol that can be used for sub objects to define that parsing will be done in the parent using the 'setValue forKey' function
public protocol EVCustomReflectable {
    static func constructWith(value: Any?) -> EVCustomReflectable?
    func constructWith(value: Any?) -> EVCustomReflectable?
    func toCodableValue() -> Any
}
