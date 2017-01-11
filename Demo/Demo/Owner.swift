
import Foundation
import EVReflection

class Owner: EVObject { // Could also use any NSObject with EVReflectable but then you should also implement most methods of EVObject (like setValue forUndefinedKey and debugDescription 
  var id: NSNumber?
  var organizationsUrl: String?
  var receivedEventsUrl: String?
  var followingUrl: String?
  var login: String?
  var avatarUrl: String?
  var Url: String?
  var subscriptionsUrl: String?
  var type: String?
  var reposUrl: String?
  var htmlUrl: String?
  var eventsUrl: String?
  var siteAdmin: Bool = false
  var starredUrl: String?
  var gistsUrl: String?
  var gravatarId: String?
  var followersUrl: String?
}
