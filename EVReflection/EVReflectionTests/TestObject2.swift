//
//  TestObject2.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

public class TestObject2:NSObject, NSCoding, Printable, Hashable, Equatable {
    var objectValue:String = ""
    
    /**
    Decode any object
    
    :param: theObject The object that we want to decode.
    :param: aDecoder The NSCoder that will be used for decoding the object.
    */
    public required convenience init(coder: NSCoder) {
        self.init()
        EVReflection.decodeObjectWithCoder(self, aDecoder: coder)
    }
    
    /**
    Encode this object using a NSCoder
    
    :param: aCoder The NSCoder that will be used for encoding the object
    */
    public func encodeWithCoder(aCoder: NSCoder) {
        EVReflection.encodeWithCoder(self, aCoder: aCoder)
    }
    
    /**
    Returns the pritty description of this object
    
    :return: The pritty description
    */
    public override var description : String {
        get {
            return EVReflection.description(self)
        }
    }
    
    /**
    Returns the hashvalue of this object
    
    :return: The hashvalue of this object
    */
    override public var hashValue : Int {
        get {
            return EVReflection.hashValue(self)
        }
    }
    
    /**
    Function for returning the hash for the NSObject based functionality
    
    :return: The hashvalue of this object
    */
    public override var hash:Int {
        get {
            return self.hashValue
        }
    }
    
    
    /**
    Implementation of the NSObject isEqual comparisson method
    
    :param: object The object where you want to compare with
    :return: Returns true if the object is the same otherwise false
    */
    public override func isEqual(object: AnyObject?) -> Bool { // for isEqual:
        if let dataObject = object as? TestObject {
            return dataObject == self // just use our "==" function
        } else { return false }
    }
}

public func ==(lhs: TestObject2, rhs: TestObject2) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

public func !=(lhs: TestObject2, rhs: TestObject2) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}
