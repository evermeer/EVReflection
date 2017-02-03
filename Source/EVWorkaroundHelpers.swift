//
//  EVWorkaroundHelpers.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 2/7/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation


/**
 Protocol for the workaround when using generics. See WorkaroundSwiftGenericsTests.swift
 */
public protocol EVGenericsKVC {
    /**
     Implement this protocol in a class with generic properties so that we can still use a standard mechanism for setting property values.
     */
    func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String)
    
    /**
     Add a function so that we can get an instance of T
     */
    func getGenericType() -> NSObject
}

/**
 Protocol for the workaround when using an enum with a rawValue of an undefined type
 */
public protocol EVRaw {
    /**
     For implementing a function that will return the rawValue for a non sepecific enum
     */
    var anyRawValue: Any { get }
}

/**
 Default implementation for getting the rawValue for any other type
 */
extension EVRaw where Self: RawRepresentable {
    var anyRawValue: Any {
        get {
            return rawValue as Any
        }
    }
}

/**
 Protocol for the workaround when using an array with nullable values
 */
public protocol EVArrayConvertable {
    /**
     For implementing a function for converting a generic array to a specific array.
     */
    func convertArray(_ key: String, array: Any) -> NSArray
}


/**
 Add a property to an enum to get the associated value
 */
public protocol EVAssociated {
}

/**
 The implrementation of the protocol for getting the associated value
 */
public extension EVAssociated {
    /**
     Easy access to the associated value of an enum.
     
     :returns: The label of the enum plus the associated value
     */
    public var associated: (label: String, value: Any?) {
        get {
            let mirror = Mirror(reflecting: self)
            if let associated = mirror.children.first {
                return (associated.label!, associated.value)
            }
            print("WARNING: Enum option of \(self) does not have an associated value")
            return ("\(self)", nil)
        }
    }
}



/**
 Dictionary extension for creating a dictionary from an array of enum values
 */
public extension Dictionary {
    /**
     Create a dictionairy based on all associated values of an enum array
     
     - parameter associated: array of dictionairy values which have an associated value
     
     */
    init<T: EVAssociated>(associated: [T]?) {
        self.init()
        if associated != nil {
            for myEnum in associated! {
                self[(myEnum.associated.label as? Key)!] = myEnum.associated.value as? Value
            }
        }
    }
}
