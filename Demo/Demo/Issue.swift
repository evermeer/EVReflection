//
//  Issue.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 20/01/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import EVReflection

class Label: EVObject {
    var id: NSNumber?
    var _default: Bool = false
    var url: String?
    var name: String?
    var color: String?
}

class Issue: EVObject {
    var identifier: NSNumber?
    var number: NSNumber?
    var title: String?
    var body: String?
    var labels: [Label]?
    var locked: Bool = false
    var url: String?
    var eventsUrl: String?
    var updatedAt: Date?
    var commentsUrl: String?
    var state: String?
    var id: NSNumber?
    var repositoryUrl: String?
    var user: GitHubUser?
    var labelsUrl: String?
    var assignees: [String]?
    var comments: NSNumber?
    var createdAt: Date?
    var htmlUrl: String?
}
