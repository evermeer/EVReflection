//
//  SignalProducerProtocol+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import ReactiveSwift
import Moya

/// Extension for processing Responses into Mappable objects through ObjectMapper
extension SignalProducerProtocol where Value == Moya.Response, Error == MoyaError {
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func map<T: EVReflectable>(to type: T.Type, forKeyPath: String? = nil) -> SignalProducer<T, Error> where T: NSObject {
        return producer.flatMap(.latest) { response -> SignalProducer<T, Error> in
            return SignalProducer(value: T(data: response.data, forKeyPath: forKeyPath))
        }
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func map<T: EVReflectable>(toArray type: T.Type, forKeyPath: String? = nil) -> SignalProducer<[T], Error> where T: NSObject {
        return producer.flatMap(.latest) { response -> SignalProducer<[T], Error> in
            return SignalProducer(value: [T](data: response.data, forKeyPath: forKeyPath))
        }
    }
}

/// Maps throwable to SignalProducer
private func unwrapThrowable<T>(_ throwable: () throws -> T) -> SignalProducer<T, Moya.MoyaError> {
    do {
        return SignalProducer(value: try throwable())
    } catch {
        return SignalProducer(error: error as! Moya.MoyaError)
    }
}
