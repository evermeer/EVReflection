//
//  DictionaryExtension.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2015 evict. All rights reserved.
//

import Foundation


/**
 Dictionary extension for creating a json strin from an array of enum values
 */
public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    /**
     Initialize a Dictionary based on a json string
     */
    init(json: String) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        for (key, value) in jsonDict {
            if let k = key as? Key, let v = value as? Value {
                self[k] = v
            }
        }
    }
    
    /**
     Initialize a Dictionary based on json data
     */
    init(data: Data) {
        self.init(json: String(data: data, encoding: .utf8) ?? "")
    }
    
    /**
     Create a json string based on this dictionary
     
     - parameter prettyPrinted: compact of pretty printed
     */
    public func toJsonString(prettyPrinted: Bool = false) -> String {
        let data = self.toJsonData(prettyPrinted: prettyPrinted)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /**
     Create a json data based on this dictionary
     
     - parameter prettyPrinted: compact of pretty printed
     */
    public func toJsonData(prettyPrinted: Bool = false) -> Data {
        do {
            if prettyPrinted {
                return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            }
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch { }
        return Data()
    }
}
