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
public extension NSMutableDictionary {
    
    /**
     Initialize a Dictionary based on a json string
     */
    convenience init(json: String) {
        self.init()
        let jsonDict = EVReflection.dictionaryFromJson(json)
        for (key, value) in jsonDict {
            self[key] = value
        }
    }
    
    /**
     Initialize a Dictionary based on json data
     */
    convenience init(data: Data) {
        self.init(json: String(data: data, encoding: .utf8) ?? "")
    }
}

public extension NSDictionary {
    /**
     Create a json string based on this dictionary
     
     - parameter prettyPrinted: compact of pretty printed
     */
    func toJsonString(prettyPrinted: Bool = false) -> String {
        let data = self.toJsonData(prettyPrinted: prettyPrinted)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /**
     Create a json data based on this dictionary
     
     - parameter prettyPrinted: compact of pretty printed
     */
    func toJsonData(prettyPrinted: Bool = false) -> Data {
        do {
            if prettyPrinted {
                return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            }
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch { }
        return Data()
    }
}


public extension NSMutableDictionary {
    
    /**
     Merge a 2nd dictionary into this one
     
     - parameter dictionary: The 2nd dictionary that will be merged into this one
     */
    func unionInPlace(dictionary: NSDictionary) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    /**
     Merge a sequence into this dictionary
     
     - parameter dictionary: The sequence that will be merged into this dictionary
     */
    func unionInPlace<S: Sequence>(sequence: S) where
        S.Iterator.Element == (Key,Value) {
            for (key, value) in sequence {
                self[key] = value
            }
    }
}
