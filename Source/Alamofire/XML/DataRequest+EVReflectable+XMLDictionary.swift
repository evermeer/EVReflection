//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 6/21/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation
import XMLDictionary
import Alamofire

public extension DataRequest {
    internal func EVReflectionXMLSerializer<T: NSObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T> where T: EVReflectable {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = self.newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let xml: String = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue) as String? ?? ""
            if let object = T(xmlString: xml, forKeyPath: keyPath) {
                return .success(object)
            } else {
                let failureReason = "Data could not be serialized. Could not get a dictionary from the XML."
                let error = self.newError(.noData, failureReason: failureReason)
                return .failure(error)
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
    public func responseObjectFromXML<T: NSObject>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self where T: EVReflectable{
        
        let serializer = self.EVReflectionXMLSerializer(keyPath, mapToObject: object)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}


