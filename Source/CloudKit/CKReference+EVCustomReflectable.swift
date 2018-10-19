//
//  CKReference+EVCustomReflectable.swift
//
//  Created by Edwin Vermeer on 1/26/18.
//  Copyright © 2016 mirabeau. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit

// We have to use custom reflection for a CKRecordID because its a special type
extension CKRecord.Reference: EVCustomReflectable  {
    public static func constructWith(value: Any?) -> EVCustomReflectable? {
        if let dict = value as? NSDictionary {
            return CKRecord.Reference(recordID: CKRecord.ID(recordName: dict["recordName"] as? String ?? ""), action: CKRecord.Reference.Action.none)
        }
        print("ERROR: Could not create CKReference for \(String(describing: value))")
        return nil
    }
    
    public func constructWith(value: Any?) -> EVCustomReflectable? {
        return CKRecord.Reference.constructWith(value: value)
    }
    
    public func toCodableValue() -> Any {
        return self.recordID.recordName
    }
}
