//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import Moya
import XMLDictionary

public extension Response {
    
    /// Maps data received from the signal into an object which implements the EVReflectable protocol.
    /// If the conversion fails, the signal errors.
    func RmapXml<T: NSObject>(to type:T.Type, forKeyPath: String? = nil) throws -> T where T: EVReflectable {
        let dict: NSDictionary = NSDictionary(xmlString: String(data: data, encoding: .utf8) ?? "") ?? NSDictionary()
        let result: T = dictMap(from: dict, forKeyPath: forKeyPath)
        return result
    }
}
