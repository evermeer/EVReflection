//
//  CKDataObject.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2017 evict. All rights reserved.
//

import CloudKit

/**
 Conversion functions from and to CKRecord plus properties for easy access to system fields.
 */
open class CKDataObject: EVObject {
    /**
     The unique ID of the record.
     */
    open var recordID: CKRecordID = CKRecordID(recordName: UUID().uuidString)
    
    /**
     The app-defined string that identifies the type of the record.
     */
    open var recordType: String!
    
    /**
     The time when the record was first saved to the server.
     */
    open var creationDate: Date = Date()
    
    /**
     The ID of the user who created the record.
     */
    open var creatorUserRecordID: CKRecordID?
    
    /**
     The time when the record was last saved to the server.
     */
    open var modificationDate: Date = Date()
    
    /**
     The ID of the user who last modified the record.
     */
    open var lastModifiedUserRecordID: CKRecordID?
    
    /**
     A string containing the server change token for the record.
     */
    open var recordChangeTag: String?
    
    /**
     Encoding the system fields so that we can create a new CKRecord based on this
     */
    open var encodedSystemFields: Data?
    
    
    /**
     Implementation of the setValue forUndefinedKey so that we can catch exceptions for when we use an optional Type like Int? in our object. Instead of using Int? you should use NSNumber?
     
     This method is in EVObject and not in NSObject extension because you would get the error: method conflicts with previous declaration with the same Objective-C selector
     
     - parameter value: The value that you wanted to set
     - parameter key: The name of the property that you wanted to set
     */
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "encodedSystemFields" && value is Data {
            encodedSystemFields = value as? Data
        } else {
            super.setValue(value, forUndefinedKey: key)
        }
    }
    
    
    // ------------------------------------------------------------------------
    // MARK: - Converting a CKRecord from and to an object
    // ------------------------------------------------------------------------
    
    /**
     Convert a CKrecord to an object
     
     - parameter record: The CKRecord that will be converted to an object
     :return: The object that is created from the record
     */
    public convenience init(_ record: CKRecord) {
        let dict = record.toDictionary()
        self.init(dictionary: dict)
        self.recordID = record.recordID
        self.recordType = record.recordType
        self.creationDate = record.creationDate ?? Date()
        self.creatorUserRecordID = record.creatorUserRecordID
        self.modificationDate = record.modificationDate ?? Date()
        self.lastModifiedUserRecordID = record.lastModifiedUserRecordID
        self.recordChangeTag = record.recordChangeTag
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        self.encodedSystemFields = data as Data
    }
    
    
    /**
     Convert an object to a CKRecord
     
     - parameter theObject: The object that will be converted to a CKRecord
     :return: The CKRecord that is created from theObject
     */
    open func toCKRecord() -> CKRecord {
        var record: CKRecord!
        if let fields = self.encodedSystemFields {
            let coder = NSKeyedUnarchiver(forReadingWith: fields)
            record = CKRecord(coder: coder)
            coder.finishDecoding()
        }
        if record == nil {
            record = CKRecord(recordType: EVReflection.swiftStringFromClass(self), recordID: self.recordID)
        }
        let (fromDict, _) = EVReflection.toDictionary(self)
        dictToCKRecord(record, dict: fromDict)
        
        return record
    }
    
    /**
     Put a dictionary recursively in a CKRecord
     
     - parameter record: the record
     - parameter dict:   the dictionary
     - parameter root:   used for expanding the property name
     */
    fileprivate func dictToCKRecord(_ record: CKRecord, dict: NSDictionary, root: String = "") {
        for (key, value) in dict {
            if !(["recordID", "recordType", "creationDate", "creatorUserRecordID", "modificationDate", "lastModifiedUserRecordID", "recordChangeTag", "encodedSystemFields"]).contains(key as! String) {
                if value is NSNull {
                    // record.setValue(nil, forKey: key) // Swift can not set a value on a nulable type.
                } else if let dict = value as? NSDictionary {
                    dictToCKRecord(record, dict: dict, root: "\(root)\(key as! String)__")
                } else if key as! String != "recordID" {
                    record.setValue(value, forKey: "\(root)\(key as! String)")
                }
            }
        }
    }
    
}

/**
 Extension for conversions from and to CKRecord
 */
public extension CKRecord {
    
    /**
     Initialize a CKRecord based on a CKDataObject
     
     - parameter dataObject: The CKDataObject
    */
    public convenience init?(_ dataObject: CKDataObject) {
        if let fields = dataObject.encodedSystemFields {
            let coder = NSKeyedUnarchiver(forReadingWith: fields)
            self.init(coder: coder)
            coder.finishDecoding()
        } else {
            self.init(recordType: EVReflection.swiftStringFromClass(dataObject), recordID: dataObject.recordID)
        }
        let (fromDict, _) = EVReflection.toDictionary(dataObject)
        dataObject.dictToCKRecord(self, dict: fromDict)
    }
    
    
    /**
     Convert a CKrecord to a CKDataObject object
     
     - parameter record: The CKRecord that will be converted to an object
     :return: The object that is created from the record
     */
    public func toDataObject() -> CKDataObject? {
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
    public func toDictionary() -> NSDictionary {
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
