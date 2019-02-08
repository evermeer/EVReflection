//
//  EVReflectionIssueX.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 14/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import XCTest

@testable import EVReflection


class TestIssueX: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssueX() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssueX", ofType: "json") ?? ""
        if let content = try? String(contentsOfFile: path) {
            print("json = \(content)")
            let data = Match(json: content)
            print("\(data)")
        } else {
            XCTAssert(true, "Could not read file")
        }
    }
    
}

public class Match: EVObject {
    public var id :NSNumber?
    public var status: MatchStatus = MatchStatus()
    public var homeMatchClub: MatchClub = MatchClub()
    public var awayMatchClub: MatchClub = MatchClub()
    public var matchPhases: [MatchPhase] = []
    public var officials: [MatchOfficial] = []
    public var nextStatuses: [MatchStatus] = []
    public var competitionRound: CompetitionRound = CompetitionRound()
    public var isAddableExtraTime: Bool = false
    public var isAddablePenalties: Bool = false
    public var score: String?
}

public class MatchPhase: EVObject {
    public var dateTimeEnd: Date?;
    public var minutesExtended: NSNumber?;
    public var resultHome: NSNumber?;
    public var id: NSNumber?;
    public var minutesRegular: String?;
    public var phaseType: MatchPhaseType = MatchPhaseType();
    public var resultAway: NSNumber?;
    public var dateTimeStart: Date?;
}

public class MatchOfficial: EVObject {
    public var id: NSNumber?;
    public var organization: MatchOrganization = MatchOrganization();
    public var referenceId: String?;
    public var type: MatchRegistrationType = MatchRegistrationType();
    public var referenceId2: String?;
    public var person: MatchPerson = MatchPerson();
}

public class MatchOrganization: EVObject {
    public var nationalID: String?
    public var zip: String?
    public var nameEN: String?
    public var locShortName: String?
    public var referenceId: String?
    public var shortNameInternational: String?
    public var regionName: String?
    public var name: String?
    public var logoPath: String?
    public var placeNameINT: String?
    public var id: String?
    public var shortNameINT: String?
    public var placeName: String?
    public var shortName: String?
    public var dateOfFoundation: String?
    public var address: String?
}

public class MatchRegistrationType: EVObject {
    public var id: NSNumber?
    public var name: String?
    public var nameKey: String?
}

public class MatchPerson: EVObject {
    public var id: NSNumber?
    public var familyName: String?
    public var nationalId: String?
    public var passportNumber: String?
    public var nameFull: String?
    public var dateOfBirth: String?
    public var firstNameINT: String?
    public var familyNameINT: String?
    public var firstName: String?
    public var shortName: String?
    public var nameFullInternationalMobile: String?
}

public class MatchStatus: EVObject {}
public class MatchClub: EVObject {}
public class CompetitionRound: EVObject {}
public class MatchPhaseType: EVObject {}


