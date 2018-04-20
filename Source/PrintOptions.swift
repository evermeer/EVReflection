//
//  PrintOptions.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/5/16.
//  Copyright © 2015 evict. All rights reserved.
//


/**
 For specifying what should be printed
 */
public struct PrintOptions: OptionSet, CustomStringConvertible {
    /// The numeric representation of the options
    public let rawValue: Int
    /**
     Initialize with a raw value
     
     - parameter rawValue: the numeric representation
     
     - returns: The Print options
     */
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// No print
    public static let None = PrintOptions(rawValue: 0)
    /// print array init uknown keypath
    public static let UnknownKeypath = PrintOptions(rawValue: 1)
    /// print EIncorrectKey
    public static let IncorrectKey = PrintOptions(rawValue: 2)
    /// print should extend an NSObject
    public static let ShouldExtendNSObject = PrintOptions(rawValue: 4)
    /// print invalid json
    public static let IsInvalidJson = PrintOptions(rawValue: 8)
    /// print Missing protocol error
    public static let MissingProtocol = PrintOptions(rawValue: 16)
    /// print Missing key error
    public static let MissingKey  = PrintOptions(rawValue: 32)
    /// print Invalid type error
    public static let InvalidType  = PrintOptions(rawValue: 64)
    /// print Invalid value error
    public static let InvalidValue  = PrintOptions(rawValue: 128)
    /// print Invalid class error
    public static let InvalidClass  = PrintOptions(rawValue: 256)
    /// print enum without associated value
    public static let EnumWithoutAssociatedValue  = PrintOptions(rawValue: 512)
    /// print enum without associated value
    public static let UseWorkaround  = PrintOptions(rawValue: 1024)

    
    /// All the options
    public static var All: PrintOptions = [UnknownKeypath, IncorrectKey, ShouldExtendNSObject, IsInvalidJson, MissingProtocol, MissingKey, InvalidType, InvalidValue, InvalidClass, EnumWithoutAssociatedValue, UseWorkaround]
    
    /// The active print options
    public static var Active: PrintOptions = All
    
    /// Get a nice description of the PrintOptions
    public var description: String {
        let strings = ["UnknownKeypath", "IncorrectKey", "ShouldExtendNSObject", "IsInvalidJson", "MissingProtocol", "MissingKey", "InvalidType", "InvalidValue", "InvalidClass", "EnumWithoutAssociatedValue", "UseWorkaround"]
        var members = [String]()
        for (flag, string) in strings.enumerated() where contains(PrintOptions(rawValue:1<<(flag + 1))) {
            members.append(string)
        }
        if members.count == 0 {
            members.append("None")
        }
        return members.description
    }
}

public func evPrint(_ options: PrintOptions, _ value: String) {
    if PrintOptions.Active.contains(options) {
        print("🌀 \(value)")
    }
}
