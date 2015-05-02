//
//  EVObject.swift
//
//  Created by Edwin Vermeer on 5/2/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

/**
Object that will support NSCoding, Printable, Hashable and Equeatable for all properties. Use this object as your base class instead of NSObject and you wil automatically have support for all these protocols.
*/
public class EVObject:NSObject, NSCoding, Printable, Hashable, Equatable {
    
    /**
    Basic init override is needed so we can use EVObject as a base class.
    */
    public override init(){
        super.init()
    }
    
    /**
    Decode any object
    
    :param: theObject The object that we want to decode.
    :param: aDecoder The NSCoder that will be used for decoding the object.
    */
    public convenience required init(coder: NSCoder) {
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
        if let dataObject = object as? EVObject {
            return dataObject == self // just use our "==" function
        } else { return false }
    }
}


/**
Implementation for Equatable ==
*/
public func ==(lhs: EVObject, rhs: EVObject) -> Bool {
    return EVReflection.areEqual(lhs, rhs: rhs)
}

/**
Implementation for Equatable !=
*/
public func !=(lhs: EVObject, rhs: EVObject) -> Bool {
    return !EVReflection.areEqual(lhs, rhs: rhs)
}

