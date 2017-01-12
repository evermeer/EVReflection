//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import Alamofire

open class EVNetworkingObject: EVObject {
    override open func initValidation(_ dict: NSDictionary) {
        if dict["__response_statusCode"] != nil {
            self.addStatusMessage(DeserializationStatus.Custom, message: "HTTP Status = \(dict["__response_statusCode"]!)")
        }
    }
    
    override open func propertyMapping() -> [(String?, String?)] {
        return [("__response_statusCode", nil)]
    }
}


public extension DataRequest {
    
    enum ErrorCode: Int {
        case noData = 1
    }
    
    internal func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofirejsontoobjects.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    internal func EVReflectionSerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = self.newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            if result.value == nil {
                let failureReason = "Data could not be serialized. Input data was not json."
                let error = self.newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            var JSONToMap: NSDictionary?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath) as? NSDictionary
            } else {
                JSONToMap = result.value as? NSDictionary
            }
            if JSONToMap == nil {
                JSONToMap = NSDictionary()
            }
            if response?.statusCode ?? 0 > 300 {
                let newDict = NSMutableDictionary(dictionary: JSONToMap!)
                newDict["__response_statusCode"] = response?.statusCode ?? 0
                JSONToMap = newDict
            }
            
            if object == nil {
                let instance: T = T()
                let parsedObject: T = ((instance.getSpecificType(JSONToMap!) as? T) ?? instance)
                let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: parsedObject)
                return .success(parsedObject)
            } else {
                let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: object!)
                return .success(object!)
            }
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where EVReflection mapping should be performed
     - parameter object: An object to perform the mapping on to
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by EVReflection.
     
     - returns: The request.
     */
    @discardableResult
    public func responseObject<T: EVObject>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        
        let serializer = self.EVReflectionSerializer(keyPath, mapToObject: object)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    
    internal func EVReflectionArraySerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = self.newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            
            var JSONToMap: NSArray?
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath) as? NSArray
            } else {
                JSONToMap = result.value as? NSArray
            }
            if JSONToMap == nil {
                JSONToMap = NSArray()
            }
            
            if response?.statusCode ?? 0 > 300  {
                if JSONToMap?.count ?? 0 > 0 {
                    let newDict = NSMutableDictionary(dictionary: JSONToMap![0] as? NSDictionary ?? NSDictionary())
                    newDict["__response_statusCode"] = response?.statusCode ?? 0
                    let newArray: NSMutableArray = NSMutableArray(array: JSONToMap!)
                    newArray.replaceObject(at: 0, with: newDict)
                    JSONToMap = newArray
                }
            }
            
            let parsedObject:[T] = (JSONToMap!).map {
                let instance: T = T()
                let _ = EVReflection.setPropertiesfromDictionary($0 as? NSDictionary ?? NSDictionary(), anyObject: instance)
                return instance
                } as [T]
            
            return .success(parsedObject)
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where EVReflection mapping should be performed
     - parameter object: An object to perform the mapping on to (parameter is not used, only here to make the generics work)
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by EVReflection.
     
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: EVObject>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let serializer = self.EVReflectionArraySerializer(keyPath, mapToObject: object)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}
