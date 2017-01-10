//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import Moya
import Xml2Dictionary

public extension Response {
    
    /// Maps data received from the signal into an object which implements the EVReflectable protocol.
    /// If the conversion fails, the signal errors.
    public func mapXml<T: EVReflectable>(to type:T.Type) throws -> T where T: NSObject {
        return map(from: Xml2Dictionary.dictionaryWithXMLData(data: data))
    }
}

