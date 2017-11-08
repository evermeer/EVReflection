//
//  DataRequest+EVReflectable.swift
//
//  Created by Edwin Vermeer on 06/01/17.
//  Copyright © 2017 Edwin Vermeer. All rights reserved.
//

import XMLDictionary

extension EVReflectable where Self: NSObject {
    /**
     Convenience init for creating an object whith an XML string
     
     - parameter xmlString: The xml string that will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init?(xmlString: String, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()

        if let result = NSDictionary(xmlString: xmlString ) {
            var XMLToMap: NSDictionary!
            if let keyPath = forKeyPath, keyPath.isEmpty == false {
                XMLToMap = result.value(forKeyPath: keyPath) as? NSDictionary ?? NSDictionary()
            } else {
                XMLToMap = result
            }
            
            let _ = EVReflection.setPropertiesfromDictionary(XMLToMap, anyObject: self, conversionOptions: conversionOptions)
        } else {
            return nil
        }
    }

    /**
     Convenience init for creating an object whith an XML string
     
     - parameter xml: The xml string that will be used to create this object
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init?(xmlData: Data?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        if xmlData == nil {
            return nil
        }
        self.init(xmlString: String(data: xmlData!, encoding: .utf8) ?? "", forKeyPath: forKeyPath)
    }
}
