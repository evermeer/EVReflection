
import Foundation
import EVReflection

class License: EVObject { // Could also use any NSObject with EVReflectable but then you should also implement most methods of EVObject (like setValue forUndefinedKey and debugDescription
    var key: String?
    var name: String?
    var spdxId: String?
    var url: String?
}

