//
//  NestedGenericsIssue25.swift
//  AlamofireJsonToObjects
//
//  Created by Edwin Vermeer on 8/3/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
import Alamofire
import EVReflection


class BaseModel: EVObject {
}

class ResponseModel<T: BaseModel>: EVObject, EVGenericsKVC {
    required init() {
        super.init()
    }

    var success: String?
    var reason: String?
    var content: [T]?

    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "content") {
            content = value as? [T]
        }
    }

    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}


class PagerModel<T: BaseModel>: BaseModel, EVGenericsKVC {
    required init() {
        super.init()
    }

    var total: String?
    var per_page: String?
    var current_page: String?
    var last_page: String?
    var next_page_url: String?
    var prev_page_url: String?
    var from: String?
    var to: String?
    var data: [T]?

    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "data") {
            data = value  as? [T]
        }
    }

    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}

class NewsHeader: BaseModel {
    var id: String?
    var Description: String?
    var newsTypeId: String?
    var newsOrder: String?
    var isCommentActive: String?
    var placeTypeId: String?
    var link: String?
    var title: String?
    var pubDate: String?
    var imageUrl: String?
    var imageThumUrl: String?
    var appId: String?
    var projectId: String?
    var isValid: String?
    var created_at: String?
    var updated_at: String?
}

protocol ResponseListener: class {
    func onResponseSuccess<T>(result: ResponseModel<T>)
    func onResponseFail(error: NSError)
}

class BaseWebServices<T: BaseModel> : NSObject {
    let BASE_URL: String = "http://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/master/AlamofireJsonToObjectsTests/"
    var listener: ResponseListener?

    func executeService(serviceUrl: String, parameters: [String: Any]) {
        let URL: String = "\(self.BASE_URL)\(serviceUrl)"
        
        Alamofire.request(URL) //, method: HTTPMethod.get, parameters: parameters, encoding: .UTF8, headers: nil)
            .responseObject { (response: DataResponse<ResponseModel<T>>) in
                switch response.result {
                case .success(let result) :
                    print("result = \(result)")
                    self.listener?.onResponseSuccess(result: result)
                    break
                case .failure(let error) :
                    print("error = \(error)")
                    self.listener?.onResponseFail(error: error as NSError)
                    break
                }
        }
    }
}



class NewsHeaderService: BaseWebServices<PagerModel<NewsHeader>>, ResponseListener {
    override  init() {
        super.init()
        super.listener = self
        executeService(serviceUrl: "NestedGenericsIssue25_json", parameters: ["token": "testtoken"])
    }

    // This initializer is just to let the test continue
    var continueTest: (() -> ())?
    convenience init(continueTest: @escaping () -> ()) {
        self.init()
        self.continueTest = continueTest
    }


    func onResponseSuccess<T>(result response: ResponseModel<T>) {
        continueTest?()
    }

    func onResponseFail(error failMessage: NSError) {
        continueTest?()
    }
}



class NestedGenericsIssue25: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(BaseModel.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testResponseObject() {
        let exp = expectation(description: "test")

        let _: NewsHeaderService = NewsHeaderService() {
            exp.fulfill()
        }

        // Fail if the test takes longer than 10 seconds.
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error.debugDescription)")
        }
    }
}
