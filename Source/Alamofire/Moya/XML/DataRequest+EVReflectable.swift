//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import Foundation
import XMLDictionary
import Alamofire

extension DataRequest {
    static var outputXMLresult: Bool = false
    
    enum ErrorCode: Int {
        case noData = 1
    }
    
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofirejsontoobjects.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    internal static func EVReflectionSerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let xml: String = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue) as? String ?? ""
            guard let object = T(xml: xml) else {
                if DataRequest.outputXMLresult {
                    print("XML string = \(xml)")
                }
                let failureReason = "Data could not be serialized. Could not get a dictionary from the XML."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            return .success(object)
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
    open func responseObject<T: EVObject>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        
        let serializer = DataRequest.EVReflectionSerializer(keyPath, mapToObject: object)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}


