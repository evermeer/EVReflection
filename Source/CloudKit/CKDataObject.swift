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
        let (fromDict, fromTypes) = EVReflection.toDictionary(self)
        dictToCKRecord(record, dict: fromDict, types: fromTypes)
        
        return record
    }
    
    /**
     Put a dictionary recursively in a CKRecord
     
     - parameter record: the record
     - parameter dict:   the dictionary
     - parameter root:   used for expanding the property name
     */
    internal func dictToCKRecord(_ record: CKRecord, dict: NSDictionary, types: NSDictionary, root: String = "") {
        for (key, value) in dict {
            if !(["recordID", "recordType", "creationDate", "creatorUserRecordID", "modificationDate", "lastModifiedUserRecordID", "recordChangeTag", "encodedSystemFields"]).contains(key as! String) {
                if value is NSNull {
                    // record.setValue(nil, forKey: key) // Swift can not set a value on a nulable type.
                } else if let dict = value as? NSDictionary {
                    if let obj: NSObject = EVReflection.swiftClassFromString(types[key] as? String ?? "") {
                        let (_, types) = EVReflection.toDictionary(obj)
                        dictToCKRecord(record, dict: dict, types: types, root: "\(root)\(key as! String)__")
                    }
                } else if key as! String != "recordID" {
                    if types[key] as? String == "CKRecordID" {
                        record.setValue(CKRecordID(recordName: value as? String ?? ""), forKey: "\(root)\(key as! String)")
                    } else if types[key] as? String == "CKReference" {
                        record.setValue(CKReference(recordID: CKRecordID(recordName: value as? String ?? ""), action: CKReferenceAction.none), forKey: "\(root)\(key as! String)")
                    } else {
                        record.setValue(value, forKey: "\(root)\(key as! String)")
                    }
                }
            }
        }
    }
    
}


