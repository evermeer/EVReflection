//
//  ArrayExtension.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2015 evict. All rights reserved.
//

import Foundation

/**
Extending Array with an some EVReflection functions where the elements can be of type NSObject
*/
public extension Array where Element: NSObject {
    
    /**
    Initialize an array based on a json string
    
    - parameter json: The json string
    - parameter conversionOptions: Option set for the various conversion options.
    */
    init(json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.arrayFromJson(type: arrayTypeInstance, json: json, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
        for item in newArray {
            self.append(item)
        }
    }


    /**
     Initialize an array based on a json string
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     */
    init(data: Data?, conversionOptions: ConversionOptions = .DefaultDeserialize, forKeyPath: String? = nil) {
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.arrayFromData(nil, type:arrayTypeInstance, data: data, conversionOptions: conversionOptions, forKeyPath: forKeyPath)
        for item in newArray {
            self.append(item)
        }
    }
    
    /**
     Initialize an array based on a dictionary
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     */
    init(dictionaryArray: [NSDictionary], conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        for item in dictionaryArray {
            let arrayTypeInstance = getArrayTypeInstance(self)
            EVReflection.setPropertiesfromDictionary(item, anyObject: arrayTypeInstance)
            self.append(arrayTypeInstance)
        }
    }

    /**
     Initialize an array based on a dictionary
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     */
    init(dictionary: NSDictionary, forKeyPath: String, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        
        guard let dictionaryArray = dictionary.value(forKeyPath: forKeyPath) as? [NSDictionary] else {
            evPrint(.UnknownKeypath, "ERROR: The forKeyPath '\(forKeyPath)' resulted in an empty array")
            return
        }
        
        for item in dictionaryArray {
            let arrayTypeInstance = getArrayTypeInstance(self)
            EVReflection.setPropertiesfromDictionary(item, anyObject: arrayTypeInstance)
            self.append(arrayTypeInstance)
        }
    }
    
    
    /**
    Get the type of the object where this array is for
    
    - parameter arr: this array
    
    - returns: The object type
    */
    func getArrayTypeInstance<T: NSObject>(_ arr: Array<T>) -> T {
        return arr.getTypeInstance()
    }
    
    /**
    Get the type of the object where this array is for
    
    - returns: The object type
    */
    func getTypeInstance<T: NSObject>(
        ) -> T {
        let nsobjectype: NSObject.Type = T.self
        let nsobject: NSObject = nsobjectype.init()
        if let obj =  nsobject as? T {
            return obj
        }
        // Could not instantiate array item instance.
        return T()
    }
    
    /**
     Get the string representation of the type of the object where this array is for
     
     - returns: The object type
     */
    func getTypeAsString() -> String {
        let item = self.getTypeInstance()
        return NSStringFromClass(type(of:item))
    }
}


/**
 Extending Array with an some EVReflection functions where the elements can be of type EVReflectable
 */
public extension Array where Element: EVReflectable {
    /**
     Convert this array to a json string
     
     - parameter conversionOptions: Option set for the various conversion options.
     - parameter prettyPrinted: Define if you want enters and indents

     - returns: The json string
     */
    func toJsonString(_ conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false) -> String {
        return "[\n" + self.map({($0).toJsonString(conversionOptions, prettyPrinted: prettyPrinted)}).joined(separator: ", \n") + "\n]"
    }

    /**
     Convert this array to a json data
     
     - parameter conversionOptions: Option set for the various conversion options.
     - parameter prettyPrinted: Define if you want enters and indents
     - parameter encoding: The string encoding defaulsts to .utf8
     
     - returns: The json data
     */
    func toJsonData(_ conversionOptions: ConversionOptions = .DefaultSerialize, prettyPrinted: Bool = false, encoding: String.Encoding = .utf8) -> Data {
        return self.toJsonString(conversionOptions, prettyPrinted: prettyPrinted).data(using: encoding) ?? Data()
    }
    
    /**
     Returns the dictionary representation of this array.
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The array of dictionaries
     */
    func toDictionaryArray(_ conversionOptions: ConversionOptions = .DefaultSerialize) -> NSArray {
        return self.map({($0).toDictionary(conversionOptions)}) as NSArray
    }
}


/**
 Extending Array with an some EVReflection functions where the elements can be of type NSObject
 */
public extension Array where Element: NSDictionary {
    
    /**
     Initialize a dictionary array based on a json string
     
     - parameter json: The json string
     */
    init(jsonArray: String) {
        self.init()

        let dictArray = EVReflection.dictionaryArrayFromJson(jsonArray)
        
        for item in dictArray {
            self.append(item as! Element)
        }
    }
    
    /**
     Initialize a dictionary array based on a json string
     
     - parameter json: The json string
     */
    init(dataArray: Data) {
        self.init(jsonArray: String(data: dataArray, encoding: .utf8) ?? "")
    }
    
    /**
     Convert this array to a json string
     
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The json string
     */
    func toJsonStringArray(prettyPrinted: Bool = false) -> String {
        let jsonArray: [String] = self.map { ($0 as NSDictionary).toJsonString(prettyPrinted: prettyPrinted) as String }
        return "[\n" + jsonArray.joined(separator: ", \n") + "\n]"
    }

}

public extension NSArray {
    func nestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[T]] {
        return (self.map {
            (($0 as? NSArray)?.map {
                element($0 as? NSDictionary ?? NSDictionary())
                }) ?? []
        })
    }
    
    func doubleNestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[[T]]] {
        return (self.map {
            (($0 as? NSArray)?.nestedArrayMap { element($0) }) ?? [[]]
        })
    }
    
    func tripleNestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[[[T]]]] {
        return (self.map {
            (($0 as? NSArray)?.doubleNestedArrayMap { element($0) }) ?? [[[]]]
        })
    }
    
    func quadrupleNestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[[[[T]]]]] {
        return (self.map {
            (($0 as? NSArray)?.tripleNestedArrayMap { element($0) }) ?? [[[[]]]]
        })
    }
    
    func quintupleNestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[[[[[T]]]]]] {
        return (self.map {
            (($0 as? NSArray)?.quadrupleNestedArrayMap { element($0) }) ?? [[[[[]]]]]
        })
    }
    
    func sextupleNestedArrayMap<T>(_ element: (NSDictionary)->T) -> [[[[[[[T]]]]]]] {
        return (self.map {
            (($0 as? NSArray)?.quintupleNestedArrayMap { element($0) }) ?? [[[[[[]]]]]]
        })
    }
    
    // If you need deeper nesting, whell, then you probably see the pattern above that you need to implement :-)
    // just name them septuple, octuple, nonuple and decuple
    // I'm not sure how far swift can handle it, but you should not want something like that.
}
