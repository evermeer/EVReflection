//
//  EVReflectionIssue159.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 14/02/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import XCTest

@testable import EVReflection


class TestIssue159: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue159() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssue159", ofType: "json") ?? ""
        if let content = try? String(contentsOfFile: path) {
            let data = DocumentDetails(json: content)
            print("\(data)")
        } else {
            XCTAssert(true, "Could not read file")
        }
    }
    
}

class DocumentDetails : EVObject{
    var reference: String?
    var documentContent: String?
    var documentAttachmentLinks : [DocumentAttachmentLink]?
    var statusCode: String?
    var message: String?
    var direction: String?
    var hasDownloadableDocuments: Bool = false
    var hasUndownloadedDocuments: Bool = false
    var sentDate: String?
    var documentTypeName: String?
    var tradingPartnerName: String?
    var success: Bool = false
    var status: NSNumber?
    var groupedDocuments: [DocumentGroup]?
    var groupId: NSNumber?
}

class DocumentAttachmentLink : EVObject {
    var attachmentId = ""
    var fileName = ""
    var dateCreated = ""
    var dateDownloaded: String?
    var documentId: String?
    var id: String?
}

class DocumentGroup: EVObject {
    var id: NSNumber?
    var reference: String?
    var documentTypeName: String?
    var status: String?
    var internalDocumentType: String?
    var label: String?
    var isLongtail: Bool = false
    var success: Bool = false
    var statusCode: NSNumber?
}
