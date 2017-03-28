//
//  Response+EVReflectable
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import Moya

public extension Response {
    
    /// Maps data received from the signal into an object which implements the EVReflectable protocol.
    /// If the conversion fails, the signal errors.
    public func map<T: EVReflectable>(to type:T.Type, forKeyPath: String? = nil) throws -> T where T: NSObject {
        let json = try mapJSON()
        var dict: NSDictionary = NSDictionary()
        if let d = json as? NSDictionary {
            dict = d
        } else if let a = json as? NSArray {
            dict = ["": a]
        }
        return map(from: dict, forKeyPath: forKeyPath)
    }
    
    /// Maps data received from the signal into an array of objects which implement the ALSwiftyJSONAble protocol
    /// If the conversion fails, the signal errors.
    public func map<T: EVReflectable>(toArray type:T.Type, forKeyPath: String? = nil) throws -> [T] where T: NSObject {
        var array: NSArray = NSArray()
        
        var json = try mapJSON()
        if forKeyPath != nil {
            guard let arr = (json as? NSDictionary)?.value(forKeyPath: forKeyPath!) else {
                print("ERROR: The forKeyPath '\(forKeyPath ?? "")' did not return an array")
                return []
            }
            json = arr
        }
        
        if let a = json as? NSArray {
            array = a
        } else if let dict = json as? NSDictionary {
            array = [dict]
        } else {
            print("ERROR: JSON mapping failed. Did not get a dictionary or array")
            return []
        }
        let parsedArray:[T] = array.map { map(from: $0 as? NSDictionary) } as [T]
        return parsedArray
    }
    
    /// Create the object from the dictionary
    internal func map<T: EVReflectable>(from: NSDictionary?, forKeyPath: String? = nil) -> T where T: NSObject {
        let instance: T = T()
        let parsedObject: T = ((instance.getSpecificType(from ?? NSDictionary()) as? T) ?? instance)
        let _ = EVReflection.setPropertiesfromDictionary(from ?? NSDictionary(), anyObject: parsedObject, forKeyPath: forKeyPath)
        if self.statusCode > 300  {
            instance.addStatusMessage(DeserializationStatus.Custom, message: "HTTP status code: \(self.statusCode)")
        }
        return parsedObject
    }
}

