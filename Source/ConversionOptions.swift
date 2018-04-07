//
//  ConversionOptions.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/5/16.
//  Copyright © 2015 evict. All rights reserved.
//


/**
 For specifying what conversion options should be executed
 */
public struct ConversionOptions: OptionSet, CustomStringConvertible {
    /// The numeric representation of the options
    public let rawValue: Int
    /**
     Initialize with a raw value
     
     - parameter rawValue: the numeric representation
     
     - returns: The ConversionOptions
     */
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// No conversion options
    public static let None = ConversionOptions(rawValue: 0)
    /// Execute property converters
    public static let PropertyConverter = ConversionOptions(rawValue: 1)
    /// Execute property mapping
    public static let PropertyMapping = ConversionOptions(rawValue: 2)
    /// Skip specific property values
    public static let SkipPropertyValue = ConversionOptions(rawValue: 4)
    /// Do a key cleanup (CameCase, snake_case)
    public static let KeyCleanup = ConversionOptions(rawValue: 8)
    /// Execute the decoding function for all values
    public static let Decoding = ConversionOptions(rawValue: 16)
    /// Execute an encoding function on all values
    public static let Encoding = ConversionOptions(rawValue: 32)
    
    // Just for bein able to show all
    public static var All: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue, KeyCleanup, Decoding, Encoding]
    /// Default used for NSCoding
    public static var DefaultNSCoding: ConversionOptions = [None]
    /// Default used for comparing / hashing functions
    public static var DefaultComparing: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue]
    /// Default used for deserialization
    public static var DefaultDeserialize: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue, KeyCleanup, Decoding]
    /// Default used for serialization
    public static var DefaultSerialize: ConversionOptions = [PropertyConverter, PropertyMapping, SkipPropertyValue, Encoding]
    
    /// Get a nice description of the ConversionOptions
    public var description: String {
        let strings = ["PropertyConverter", "PropertyMapping", "SkipPropertyValue", "KeyCleanup", "Decoding", "Encoding"]
        var members = [String]()
        for (flag, string) in strings.enumerated() where contains(ConversionOptions(rawValue:1<<(flag + 1))) {
            members.append(string)
        }
        if members.count == 0 {
            members.append("None")
        }
        return members.description
    }
}
