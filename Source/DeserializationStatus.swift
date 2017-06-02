//
//  DeserializationStatus.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/5/16.
//  Copyright © 2015 evict. All rights reserved.
//

/**
 Type of status messages after deserialization
 */
public struct DeserializationStatus: OptionSet, CustomStringConvertible {
    /// The numeric representation of the options
    public let rawValue: Int
    /**
     Initialize with a raw value
     
     - parameter rawValue: the numeric representation
     
     - returns: the DeserializationStatus
     */
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// No status message
    public static let None = DeserializationStatus(rawValue: 0)
    /// Incorrect key error
    public static let IncorrectKey  = DeserializationStatus(rawValue: 1)
    /// Missing key error
    public static let MissingKey  = DeserializationStatus(rawValue: 2)
    /// Invalid type error
    public static let InvalidType  = DeserializationStatus(rawValue: 4)
    /// Invalid value error
    public static let InvalidValue  = DeserializationStatus(rawValue: 8)
    /// Invalid class error
    public static let InvalidClass  = DeserializationStatus(rawValue: 16)
    /// Missing protocol error
    public static let MissingProtocol  = DeserializationStatus(rawValue: 32)
    /// Custom status message
    public static let Custom  = DeserializationStatus(rawValue: 64)
    
    /// Get a nice description of the DeserializationStatus
    public var description: String {
        let strings = ["IncorrectKey", "MissingKey", "InvalidType", "InvalidValue", "InvalidClass", "MissingProtocol", "Custom"]
        var members = [String]()
        for (flag, string) in strings.enumerated() where contains(DeserializationStatus(rawValue:1<<(flag))) {
            members.append(string)
        }
        if members.count == 0 {
            members.append("None")
        }
        return members.description
    }
}
