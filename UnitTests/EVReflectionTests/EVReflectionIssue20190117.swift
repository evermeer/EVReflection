//
//  EVReflectionIssue20190117.swift
//  UnitTestsiOS
//
//  Created by Edwin Vermeer on 17/01/2019.
//  Copyright © 2019 evict. All rights reserved.
//


import Foundation
import XCTest
import EVReflection
import RealmSwift

class EVReflectionIssue20190117: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(ColorConfigurationModel.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEVReflectionIssue20190117() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssue20190117", ofType: "json") ?? ""
        if let content = try? String(contentsOfFile: path) {
            let data = ColorConfigurationModel(json: content)
            print("\(data)")
        } else {
            XCTAssert(true, "Could not read file")
        }
    }

}


open class ColorConfigurationModel: EVObject {

    public static var sharedInstance = ColorConfigurationModel()

    //open var id = 0
    open var BarColors: BarColorsModel?
    open var ButtonColors: ButtonColorsModel?
    open var TextColors: TextColorsModel?
    open var ViewColors: ViewColorsModel?
    open var BorderColors: BorderColorsModel?
}

open class BarColorsModel: EVObject {
    open var navBar: String?
    open var toolBar: String?
}

open class ButtonColorsModel: EVObject {
    open var buttonBackground: String?
    open var buttonText: String?
    open var locationTint: String?
}

open class TextColorsModel: EVObject {
    open var title: String?
    open var label: String?
    open var dark: String?
    open var textfield: String?
    open var placeholder: String?
    open var navigationTitle: String?
}

open class ViewColorsModel: EVObject {
    open var background: String?
    open var leftMenuBackground: String?
    open var textfieldBackground: String?
    open var lineBackground: String?
    open var calendarContainerBg: String?
    open var blankViewBg: String?
    open var dot: String?
    open var empty: String?
}

open class BorderColorsModel: EVObject {
    open var textfield: String?
}
