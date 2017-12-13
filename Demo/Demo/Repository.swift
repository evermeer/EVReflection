
import Foundation
import EVReflection

class Repository: EVObject { // Could also use any NSObject with EVReflectable but then you should also implement most methods of EVObject (like setValue forUndefinedKey and debugDescription 
    var owner: Owner?
    var license: License?
    
    var keysUrl: String?
    var statusesUrl: String?
    var issuesUrl: String?
    var defaultBranch: String?
    var issueEventsUrl: String?
    var id: NSNumber?
    var eventsUrl: String?
    var subscriptionUrl: String?
    var watchers: NSNumber?
    var gitCommitsUrl: String?
    var subscribersUrl: String?
    var subscribersCount: NSNumber?
    var networkCount: NSNumber?
    var cloneUrl: String?
    var hasWiki: Bool = false
    var Url: String?
    var pullsUrl: String?
    var fork: Bool = false
    var notificationsUrl: String?
    var _description: String?
    var collaboratorsUrl: String?
    var deploymentsUrl: String?
    var languagesUrl: String?
    var hasIssues: Bool = false
    var commentsUrl: String?
    var isPrivate: Bool = false
    var size: NSNumber?
    var gitTagsUrl: String?
    var updatedAt: String?
    var sshUrl: String?
    var name: String?
    var contentsUrl: String?
    var archiveUrl: String?
    var milestonesUrl: String?
    var blobsUrl: String?
    var contributorsUrl: String?
    var openIssuesCount: NSNumber?
    var forksCount: NSNumber?
    var treesUrl: String?
    var svnUrl: String?
    var commitsUrl: String?
    var createdAt: String?
    var forksUrl: String?
    var hasDownloads: Bool = false
    var mirrorUrl: String?
    var homepage: String?
    var teamsUrl: String?
    var branchesUrl: String?
    var issueCommentUrl: String?
    var mergesUrl: String?
    var gitRefsUrl: String?
    var gitUrl: String?
    var forks: NSNumber?
    var openIssues: NSNumber?
    var hooksUrl: String?
    var htmlUrl: String?
    var stargazersUrl: String?
    var assigneesUrl: String?
    var compareUrl: String?
    var fullName: String?
    var tagsUrl: String?
    var releasesUrl: String?
    var pushedAt: String?
    var labelsUrl: String?
    var downloadsUrl: String?
    var stargazersCount: NSNumber?
    var watchersCount: NSNumber?
    var language: String?
    var hasPages: Bool = false
    var hasProjects: Bool = false
    var archived: String?
}
