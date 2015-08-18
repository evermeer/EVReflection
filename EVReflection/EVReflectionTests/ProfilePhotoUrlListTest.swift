import UIKit
import XCTest

/**
Testing EVReflection for Json
*/
class ProfilePhotoUrlListTests: XCTestCase {
    
    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }
    
    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testJsonObject(){
        
        let jsonDictOriginal = ["meta": ["limit": 1000, "offset": 0, "total_count": 4], "objects": [["id": 35, "index": 1, "resource_uri": "/api/v1/profilephotourl/35/", "url": "a", "user": "/api/v1/user/1/"], ["id": 37, "index": 0, "resource_uri": "/api/v1/profilephotourl/37/", "url": "b", "user": "/api/v1/user/1/"], ["id": 36, "index": 3, "resource_uri": "/api/v1/profilephotourl/36/", "url": "c", "user": "/api/v1/user/1/"], ["id": 44, "index": 2, "resource_uri": "/api/v1/profilephotourl/44/", "url": "d", "user": "/api/v1/user/1/"]]]
        
        print("Initial dictionary:\n\(jsonDictOriginal)\n\n")
        
        let profilePhotoUrlListOriginal = ProfilePhotoUrlList(dictionary: jsonDictOriginal)
        print("Dictionary to an object: \n\(profilePhotoUrlListOriginal)\n\n")
        
        let jsonString = profilePhotoUrlListOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")
        
        let profilePhotoUrlListRegenerated = ProfilePhotoUrlList(json:jsonString)
        print("Object from json string: \n\(profilePhotoUrlListRegenerated)\n\n")
        
        if profilePhotoUrlListOriginal == profilePhotoUrlListRegenerated {
            XCTAssert(true, "Success")
        } else {
            XCTAssert(false, "Faileure")
        }
    }
    
}

class Base: EVObject {
    var resource_uri: String?
    
    func getResourceId() -> String! {
        return resource_uri?.componentsSeparatedByString("/").last
    }
}

class Meta : EVObject {
    var limit : Int = 0
    var next : String?
    var offset : Int = 0
    var previous : String?
    var total_count : Int = 0
}

class ProfilePhotoUrl : Base {
    var url : String?
    var index : Int = 0
    var user : String?
    var id : Int = 0
}

class ProfilePhotoUrlList : EVObject {
    var meta: Meta?
    var objects: [ProfilePhotoUrl]?
}