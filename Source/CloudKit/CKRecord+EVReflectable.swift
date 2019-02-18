//
//  CKRecord+EVReflectable.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2017 evict. All rights reserved.
//

import CloudKit

/**
 Extension for conversions from and to CKRecord
 */
public extension CKRecord {
    
    /**
     Initialize a CKRecord based on a CKDataObject
     
     - parameter dataObject: The CKDataObject
     */
    convenience init?(_ dataObject: CKDataObject) {
        if let fields = dataObject.encodedSystemFields {
            let coder = NSKeyedUnarchiver(forReadingWith: fields)
            self.init(coder: coder)
            coder.finishDecoding()
        } else {
            self.init(recordType: EVReflection.swiftStringFromClass(dataObject), recordID: dataObject.recordID)
        }
        let (fromDict, fromTypes) = EVReflection.toDictionary(dataObject)
        dataObject.dictToCKRecord(self, dict: fromDict, types: fromTypes)
    }
    
    
    /**
     Convert a CKrecord to a CKDataObject object
     
     - parameter record: The CKRecord that will be converted to an object
     :return: The object that is created from the record
     */
    func toDataObject() -> CKDataObject? {
        if let theObject = EVReflection.fromDictionary(self.toDictionary(), anyobjectTypeString: self.recordType) as? CKDataObject {
            theObject.recordID = self.recordID
            theObject.recordType = self.recordType
            theObject.creationDate = self.creationDate ?? Date()
            theObject.creatorUserRecordID = self.creatorUserRecordID
            theObject.modificationDate = self.modificationDate ?? Date()
            theObject.lastModifiedUserRecordID = self.lastModifiedUserRecordID
            theObject.recordChangeTag = self.recordChangeTag
            
            let data = NSMutableData()
            let coder = NSKeyedArchiver(forWritingWith: data)
            self.encodeSystemFields(with: coder)
            coder.finishEncoding()
            theObject.encodedSystemFields = data as Data
            return theObject
        }
        return nil
    }
    
    /**
     Convert CKRecord to dictionary
     
     :return: The dictionary that is created from the record
     */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        for key in self.allKeys() {
            if let value = self.object(forKey: key) {
                var path: [String] = key.components(separatedBy: "__")
                if path.count == 1 {
                    dictionary.setObject(value, forKey: key as NSCopying)
                } else {
                    var tempDict = dictionary
                    var tempKey = key
                    let lastKey = path[path.count - 1]
                    path.removeLast()
                    for item in path {
                        tempKey = item
                        if tempDict[tempKey] == nil {
                            tempDict.setObject(NSMutableDictionary(), forKey: tempKey as NSCopying)
                        }
                        tempDict = (tempDict[tempKey] as? NSMutableDictionary) ?? NSMutableDictionary()
                    }
                    tempDict.setObject(value, forKey: lastKey as NSCopying)
                }
            }
        }
        return dictionary
    }
}
