//
//  EVReflectionExtendingNSObjects.swif.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 18/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import EVReflection


// You can have any object that has NSObject as its base class
public class ExtendingNSObjects: NSObject {
}

// And then extend it with the EVReflectable protocol using only:
extension ExtendingNSObjects: EVReflectable { }

// You could for instance do this for a Realm Object or a Core data NSMAnagedObject



// It is adviced to add an implementation for the 'setValue forUndefinedKey' to prevent crashes. 
// You cod do that like this:

public class ExtendingNSObjectsMore: NSObject {
}

extension ExtendingNSObjectsMore: EVReflectable {
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let kvc = self as? EVGenericsKVC {
            kvc.setGenericValue(value as AnyObject?, forUndefinedKey: key)
        } else {
            self.addStatusMessage(.IncorrectKey, message: "The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'")
            print("\nWARNING: The class '\(EVReflection.swiftStringFromClass(self))' is not key value coding-compliant for the key '\(key)'\n There is no support for optional type, array of optionals or enum properties.\nAs a workaround you can implement the function 'setValue forUndefinedKey' for this. See the unit tests for more information\n")
            
        }
    }
}


// And you could extend it with a property level iEqual or advanced description and debugDescription functions

extension ExtendingNSObjectsMore {

    open override func isEqual(_ object: Any?) -> Bool { // for isEqual:
        if let obj = object as? EVObject {
            return EVReflection.areEqual(self, rhs: obj)
        }
        return false
    }
    
    open override var description: String {
        get {
            return EVReflection.description(self, prettyPrinted: true)
        }
    }
    
    open override var debugDescription: String {
        get {
            return EVReflection.description(self, prettyPrinted: true)
        }
    }
}


// If you do want NSCoding support, then you need to create it in your own class. You could make this generic for all your objects by putting it in a base class.

public class ExtendingNSObjectsCoding: ExtendingNSObjectsMore, NSCoding {
    public convenience required init?(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder, conversionOptions: .DefaultNSCoding)
    }
    
    open func encode(with aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self , aCoder: aCoder, conversionOptions: .DefaultNSCoding)
    }
}



