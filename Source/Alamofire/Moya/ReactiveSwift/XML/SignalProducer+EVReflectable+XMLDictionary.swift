//
//  SignalProducerProtocol+EVReflectable+XMLDictionary.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import ReactiveSwift
import Moya
import EVReflection

/// Extension for processing Responses into Mappable objects through ObjectMapper
extension SignalProducerProtocol where Value == Moya.Response, Error == MoyaError {
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapXml<T: EVReflectable>(to type: T.Type) -> SignalProducer<T, Error> where T: NSObject {
        return producer.flatMap(.latest) { response -> SignalProducer<T, Error> in
            if let result = T(xmlData: response.data) {
                return SignalProducer(value: result)
            }
            return SignalProducer(value: T())
        }
    }
}
