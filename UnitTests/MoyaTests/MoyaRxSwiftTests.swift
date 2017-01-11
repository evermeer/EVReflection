//
//  MoyaRxSwiftTests.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 11/01/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import XCTest
import Moya
import RxSwift
import EVReflection

class MoyaRxSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // When running EVReflection outside of your main bundle, you have to specify where to find the objects
        EVReflection.setBundleIdentifier(Repository.self)
    }
    
    var disposeBag = DisposeBag()
    
    func testDownloadRepositories() {
        let expectation = self.expectation(description: "evermeer")
        
        GitHubRxMoyaProvider.request(.userRepositories("evermeer"))
            .map(toArray: Repository.self)
            .subscribe { event -> Void in
                switch event {
                case .next(let repos):
                    print("result = \(repos)")
                    let evr = repos.first { $0.name == "EVReflection"}
                    XCTAssert(evr?.owner?.login == "evermeer", "This should have been my library!")
                    expectation.fulfill()
                case .error(let error):
                    print("error = \(error)")
                    XCTAssert(false, "no result from service")
                default:
                    break
                }
            }.addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDownloadUserProfile() {
        let expectation = self.expectation(description: "evermeer")
        
        GitHubRxMoyaProvider.request(.userProfile("evermeer"))
            .map(to: GitHubUser.self)
            .subscribe { event -> Void in
                switch event {
                case .next(let result):
                    print(result)
                    expectation.fulfill()
                case .error(let error):
                    XCTAssert(false, "no result from service")
                    print(error)
                default:
                    break
                }
            }.addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }

    
    func testDownloadZen() {
        let expectation = self.expectation(description: "evermeer")

        GitHubRxMoyaProvider.request(.zen)
            .subscribe { event -> Void in
                switch event {
                case .next(let result):
                    let message = (try? result.mapString()) ?? "Couldn't access API"
                    print(message)
                    expectation.fulfill()
                case .error(let error):
                    XCTAssert(false, "no result from service")
                    print(error)
                default:
                    break
                }
            }.addDisposableTo(disposeBag)

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
