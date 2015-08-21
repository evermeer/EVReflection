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
    var bundleName: String = ""
    var className: String = ""
    var classPath: [String] = []
    var classPathType: [ObjectType] = []
    var swiftClassID: String = ""
    
    public enum ObjectType:String {
        case Target = "t"
        case Class = "C"
        case Protocol = "P"
        case Function = "F"
    }
    
    public init(forObject: NSObject) {
        bundleName = EVReflection.getCleanAppName()
        swiftClassID = NSStringFromClass(forObject.dynamicType)
        
        if (swiftClassID.hasPrefix("_T")) {
            parseTypes((swiftClassID as NSString).substringFromIndex(2))
            bundleName = classPath[0]
            className = classPath.last!
        } else {
            // Root objects will already have a . notation
            classPath = split(swiftClassID) {$0 == "."}
            if classPath.count > 1 {
                bundleName = classPath[0]
                className = classPath.last!
                classPathType = [ObjectType](count: classPath.count, repeatedValue: ObjectType.Class)
                classPathType[0] = .Target
            } else {
                NSLog("WARNING: Unhandled class string parsing for \(swiftClassID)")
            }
        }
    }
    
    private func parseTypes(classString:String) {
        let characters = Array(classString)
        let type:String = String(characters[0])
        if type.toInt() == nil {
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
    
    private func parseNames(classString:String) {
        let characters = Array(classString)
        let type:String = String(characters[0])
        var numForName = ""
        var index = 0
        while String(characters[index]).toInt() != nil {
            numForName.append(characters[index])
            index++
        }
        var range = Range<String.Index>(start:advance(classString.startIndex, index), end:advance(classString.startIndex, numForName.toInt()! + index))
        let name = classString.substringWithRange(range)
        classPath.append(name)
        if classPathType[classPath.count - 1] == .Function {
            //TODO: reverse engineer function description. For now only allow parameterless function that return void (FS0_FT_T_L_)
            index = index + 11
        }
        if characters.count > index + numForName.toInt()! {
            parseNames((classString as NSString).substringFromIndex(index + numForName.toInt()!))
        }
    }
}
