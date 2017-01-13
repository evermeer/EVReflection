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
    public func mapXml<T: EVReflectable>(to type:T.Type) throws -> T where T: NSObject {
        let dict: NSDictionary = NSDictionary(xmlString: String(data: data, encoding: .utf8) ?? "") ?? NSDictionary()
        let result: T = map(from: dict)
        return result
    }
}
