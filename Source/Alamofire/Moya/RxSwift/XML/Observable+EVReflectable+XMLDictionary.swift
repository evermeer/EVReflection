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
    public func mapXml<T: EVReflectable>(to type: T.Type) -> Observable<T> where T: NSObject {
        return flatMap { response -> Observable<T> in
            let result = try response.mapXml(to: T.self)
            return Observable.just(result)
        }
    }
}
