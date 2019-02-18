//
//  EVManagedObjectArrayExtension.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2015 evict. All rights reserved.
//

import Foundation
import CoreData

/**
 Extending Array with an some EVReflection functions where the elements can be of type NSObject
 */
public extension Array where Element: EVManagedObject {
    
    /**
     Initialize an array based on a json string
     
     - parameter json: The json string
     - parameter conversionOptions: Option set for the various conversion options.
     */
    init(context: NSManagedObjectContext, json: String?, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        let dictArray: [NSDictionary] = EVReflection.dictionaryArrayFromJson(json)
        for item in dictArray {
            let arrayTypeInstance = getArrayTypeInstance(self, context: context)
            EVReflection.setPropertiesfromDictionary(item, anyObject: arrayTypeInstance, conversionOptions: conversionOptions)
            self.append(arrayTypeInstance)
        }
    }
    
    
    /**
     Get the type of the object where this array is for
     
     - parameter arr: this array
     
     - returns: The object type
     */
    func getArrayTypeInstance<T: EVManagedObject>(_ arr: Array<T>, context: NSManagedObjectContext) -> T {
        return arr.getTypeInstance(context: context)
    }
    
    /**
     Get the type of the object where this array is for
     
     - returns: The object type
     */
    func getTypeInstance<T: EVManagedObject>(context: NSManagedObjectContext) -> T {
        let nsobjectype: EVManagedObject.Type = T.self
        let name = EVReflection.swiftStringFromClass(nsobjectype)
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { return T() }
        let nsobject: EVManagedObject = nsobjectype.init(entity: entity, insertInto: context)
        
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

