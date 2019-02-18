//
//  Observable+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import RxSwift
import Moya

/// Extension for processing Responses into Mappable objects through ObjectMapper
public extension ObservableType where E == Response {

    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    func Rmap<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Observable<T> where T: EVReflectable {
    return flatMap { response -> Observable<T> in
        let result = try response.Rmap(to: T.self, forKeyPath: forKeyPath)
        return Observable.just(result)
      }
    }

    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    func RmapArray<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Observable<[T]>  where T: EVReflectable {
    return flatMap { response -> Observable<[T]> in
        let result = try response.RmapArray(to: T.self, forKeyPath: forKeyPath)
        return Observable.just(result)
      }
    }

    func RmdArray<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Observable<[[T]]>  where T: EVReflectable {
        return flatMap { response -> Observable<[[T]]> in
            let result = try response.RmapNestedArray(to: T.self, forKeyPath: forKeyPath)
            return Observable.just(result)
        }
    }

}


// Extension for processing Responses into EVReflectable objects through EVReflection
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    
    /// Maps data received from the signal into an object (on the default Background thread) which
    /// implements the EVReflectable protocol and returns the result back on the MainScheduler.
    /// If the conversion fails, the signal errors.
    func Rmap<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Single<T> where T: EVReflectable {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Single<T> in
                return Single.just(try response.Rmap(to: type, forKeyPath: forKeyPath))
            }
            .observeOn(MainScheduler.instance)
    }
    
    /// Maps data received from the signal into an array of objects (on the default Background thread)
    /// which implement the EVReflectable protocol and returns the result back on the MainScheduler
    /// If the conversion fails, the signal errors.
    func RmapArray<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Single<[T]> where T: EVReflectable {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Single<[T]> in
                return Single.just(try response.RmapArray(to: type, forKeyPath: forKeyPath))
            }
            .observeOn(MainScheduler.instance)
    }
    
    /// Maps data received from the signal into an array of objects (on the default Background thread)
    /// which implement the EVReflectable protocol and returns the result back on the MainScheduler
    /// If the conversion fails, the signal errors.
    func RmapNestedArray<T: NSObject>(to type: T.Type, forKeyPath: String? = nil) -> Single<[[T]]> where T: EVReflectable {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Single<[[T]]> in
                return Single.just(try response.RmapNestedArray(to: type, forKeyPath: forKeyPath))
            }
            .observeOn(MainScheduler.instance)
    }
}

