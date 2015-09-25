//
//  EVObjectDescription.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 8/19/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import Foundation

/**
Generate a description for an object by extracting information from the NSStringFromClass
*/
public class EVObjectDescription {
    /// The name of the bundle
    public var bundleName: String = ""
    /// The name of the class
    public var className: String = ""
    /// The classpath starting from the bundle
    public var classPath: [String] = []
    /// The types of the items in the classpath
    public var classPathType: [ObjectType] = []
    /// The string representation used by Swift for the classpath
    public var swiftClassID: String = ""
    
    /**
    Enum for the difrent types that can be part of an object description
    */
    public enum ObjectType:String {
        /// The target or bunldle
        case Target = "t"
        /// The Class
        case Class = "C"
        /// The Protocol
        case Protocol = "P"
        /// The function
        case Function = "F"
    }
    
    /**
    Initialize an instance and set all properties based on the object
    
    :parameter: forObject the object that you want the description for
    */
    public init(forObject: NSObject) {
        bundleName = EVReflection.getCleanAppName()
        swiftClassID = NSStringFromClass(forObject.dynamicType)
        
        if (swiftClassID.hasPrefix("_T")) {
            parseTypes((swiftClassID as NSString).substringFromIndex(2))
            bundleName = classPath[0]
            className = classPath.last!
        } else {
            // Root objects will already have a . notation
            classPath = swiftClassID.characters.split(isSeparator: {$0 == "."}).map({String($0)})
            if classPath.count > 1 {
                bundleName = classPath[0]
                className = classPath.last!
                classPathType = [ObjectType](count: classPath.count, repeatedValue: ObjectType.Class)
                classPathType[0] = .Target
            }
        }
    }
    
    /**
    Get all types from the class string
    
    :parameter: classString the string representation of a class
    
    :returns: Nothing
    */
    private func parseTypes(classString:String) {
        let characters = Array(classString.characters)
        let type:String = String(characters[0])
        if Int(type) == nil {
            let ot: ObjectType = ObjectType(rawValue: type)!
            if ot == .Target {
                classPathType.append(ot)
            } else {
                classPathType.insert(ot, atIndex: 1) // after Target all types are in reverse order
            }
            parseTypes((classString as NSString).substringFromIndex(1))
        } else {
            parseNames(classString)
        }
    }
    
    /**
    Get all the names from the class string
    
    :parameter: classString the string representation of the class
    
    :returns: Nothing
    */
    private func parseNames(classString:String) {
        let characters = Array(classString.characters)
        var numForName = ""
        var index = 0
        while Int(String(characters[index])) != nil {
            numForName = "\(numForName)\(characters[index])"
            index++
        }
        let range = Range<String.Index>(start:classString.startIndex.advancedBy(index), end:classString.startIndex.advancedBy((Int(numForName) ?? 0) + index))
        let name = classString.substringWithRange(range)
        classPath.append(name)
        if name == "" {
            return
        }
        if classPathType[classPath.count - 1] == .Function {
            //TODO: reverse engineer function description. For now only allow parameterless function that return void (FS0_FT_T_L_)
            index = index + 11
        }
        if characters.count > index + Int(numForName)! {
            parseNames((classString as NSString).substringFromIndex(index + Int(numForName)!))
        }
    }
}
