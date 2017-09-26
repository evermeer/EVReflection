//
//  Observable+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import RxSwift
import Moya

/// Extension for processing Responses into EVReflectable objects through EVReflection
public extension ObservableType where E == Response {

    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func RmapXml<T: NSObject>(to type: T.Type) -> Observable<T> where T: EVReflectable {
        return flatMap { response -> Observable<T> in
            let result = try response.RmapXml(to: T.self)
            return Observable.just(result)
        }
    }
}

// Extension for processing Responses into EVReflectable objects through EVReflection
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    
    /// Maps data received from the signal into an object (on the default Background thread) which
    /// implements the EVReflectable protocol and returns the result back on the MainScheduler.
    /// If the conversion fails, the signal errors.
    public func RmapXml<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Single<T> where T: EVReflectable {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Single<T> in
                return Single.just(try response.RmapXml(to: type, forKeyPath: forKeyPath))
            }
            .observeOn(MainScheduler.instance)
    }
}
