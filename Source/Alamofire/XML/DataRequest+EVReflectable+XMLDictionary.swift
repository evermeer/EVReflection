//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 6/21/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation
import Xml2Dictionary
import Alamofire

extension DataRequest {
    open static var outputXMLresult: Bool = false
    
    internal static func EVReflectionXMLSerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let object = T()
            let xml: String = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue) as? String ?? ""
            if let result = NSDictionary(xmlString: xml ) {
                if DataRequest.outputXMLresult {
                    print("Dictionary from XML = \(result)")
                }
                
                var XMLToMap: NSDictionary!
                if let keyPath = keyPath, keyPath.isEmpty == false {
                    XMLToMap = result.value(forKeyPath: keyPath) as? NSDictionary ?? NSDictionary()
                } else {
                    XMLToMap = result
                }
                
                let _ = EVReflection.setPropertiesfromDictionary(XMLToMap, anyObject: object)
                return .success(object)
            } else {
                if DataRequest.outputXMLresult {
                    print("XML string = \(xml)")
                }
                let failureReason = "Data could not be serialized. Could not get a dictionary from the XML."
                let error = newError(.noData, failureReason: failureReason)
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
    open func responseObjectFromXML<T: EVObject>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        
        let serializer = DataRequest.EVReflectionXMLSerializer(keyPath, mapToObject: object)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}


