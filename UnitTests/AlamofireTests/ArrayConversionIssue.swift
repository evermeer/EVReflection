//
//  ArrayConversionIssue.swift
//  AlamofireJsonToObjects
//
//  Created by Edwin Vermeer on 26/09/2016.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
import Alamofire
import EVReflection


class ListResponse<T: NSObject>: EVObject, EVGenericsKVC {
    var status : Int        = 0
    var reason : String     = ""
    var model  : Array<T>   = Array()
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key {
        case "model":
            model = value as! Array<T>
            break
        default:
            print("Missing expected field <\(key)> in list response!")
            break
        }
    }
    
    func getGenericType() -> NSObject {
        return T()
    }
    
    func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        print(key)
    }
}


class ShoppingList: EVObject {
    var id: Int64                    = 0
    var name: String                   = ""
    var products: [ShoppingListProduct] = []
}

class ShoppingListProduct: BaseProduct {
    var amount: Int = 0
}


enum ProductStatus {
    case None
    case Visible
}

class BaseProduct: EVObject {
    var id: Int64         = 0
    var name: String        = ""
    var retailPrice: Double        = 0.0
    var maxOrderAmount: Int           = 0
    var image: String        = ""
    var sale: Sale          = Sale()
    var features: Array<String> = Array()
    var status: ProductStatus = .None
    var shortDescription: String = ""
    var brand: String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "status" {
            if (value as? String ?? "") == "Visible" {
                status = .Visible
            } else {
                status = .None
            }
            return
        }
        print("Key <\(key)> is not defined for sale!")
    }
}



class Sale: EVObject, EVArrayConvertable {
    var desc: String        = ""
    var salePercent: String        = ""
    var salePrice: Double        = 0
    var amount: Int           = 0
    var endDate: String        = ""
    var productIds: [Int]         = []
    var images: Array<String> = Array()
    
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key {
        case "description":
            desc = value as! String
            break
        default:
            print("Key <\(key)> is not defined for sale!")
        }
    }
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        switch key {
        case "productIds":
            print("\(array)")
        default:
            break
        }
        return []
    }
}


class AlamofireArrayConversionIssue: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Sale.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseObject() {
        let URL:URLConvertible = "https://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/Swift3/AlamofireJsonToObjectsTests/ArrayConversionIssue_json"
        let exp = expectation(description: "\(URL)")
        
        Alamofire.request(URL)
            .responseObject { (response: DataResponse<ListResponse<ShoppingList>>) in
                exp.fulfill()
                
                if let result = response.result.value {
                    print("\(result.description)")
                }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
