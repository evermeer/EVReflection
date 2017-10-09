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
        let expectation = self.expectation(description: "testDownloadRepositories")
        
        //        GitHubRxMoyaProvider.rx.request(.userRepositories("evermeer")).subscribe { (result) in
        GitHubRxMoyaProvider.request(.userRepositories("evermeer")) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.RmapArray(to: Repository.self)
                    print("result = \(parsed)")
                    let evr = parsed.first { $0.name == "EVReflection"}
                    XCTAssert(evr?.owner?.login == "evermeer", "This should have been my library!")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "" )")
        }
    }

    func testDownloadUserProfile() {
        let expectation = self.expectation(description: "testDownloadUserProfile")

        //        GitHubRxMoyaProvider.rx.request(.userProfile("evermeer")).subscribe { (result) in

        GitHubRxMoyaProvider.request(.userProfile("evermeer")) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.Rmap(to: GitHubUser.self)
                    print("result = \(parsed)")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }

    func testDownloadRepositoryInfo() {
        let expectation = self.expectation(description: "testDownloadRepositoryInfo")

        //         GitHubRxMoyaProvider.rx.request(.repo("evermeer/EVReflection")).subscribe { (result) in
        GitHubRxMoyaProvider.request(.repo("evermeer/EVReflection")) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.Rmap(to: Repository.self)
                    print("result = \(parsed)")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }

    func testDownloadRepositoryIssues() {
        let expectation = self.expectation(description: "testDownloadRepositoryIssues")
        
        GitHubRxMoyaProvider.request(.issues("evermeer/EVReflection")) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.RmapArray(to: Issue.self)
                    print("result = \(parsed)")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
    
    func testDownloadWheatherResponseRxSwiftXML() {
        let expectation = self.expectation(description: "testDownloadWheatherResponseRxSwiftXML")
        
         GitHubRxMoyaProvider.request(.xml) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.RmapXml(to: WeatherResponse.self)
                    print("result = \(parsed)")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }

    func testDownloadWeatherResponseXML() {
        let expectation = self.expectation(description: "testDownloadWeatherResponseXML")
        
        GitHubMoyaProvider.request(.xml, completion: { result in
            var success = true
            var message = "Could not parse XML"
            switch result {
            case let .success(response):
                do {
                    let repos: WeatherResponse? = try response.RmapXml(to: WeatherResponse.self)
                    if repos != nil {
                        print("WeatherResponse = \(repos!)")
                        expectation.fulfill()
                    } else {
                        success = false
                    }
                } catch {
                    message = error.localizedDescription
                    success = false
                }
            case let .failure(error):
                message = error.localizedDescription
                success = false
            }
            
            XCTAssert(success, message)
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
    
    
    
    func testDownloadZen() {
        let expectation = self.expectation(description: "testDownloadZen")

        GitHubRxMoyaProvider.request(.zen) { (result) in
            switch result {
            case .success(let response):
                let message = (try? response.mapString()) ?? "Couldn't access API"
                print(message)
                expectation.fulfill()
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
    
    func testNestedArray() {
        let expectation = self.expectation(description: "testNestedArray")
        
        GitHubRxMoyaProvider.request(.nestedArray) { (result) in
            switch result {
            case .success(let response):
                do {
                    let parsed = try response.RmapNestedArray(to: Issue.self)
                    print("result = \(parsed)")
                    expectation.fulfill()
                } catch let error {
                    print("parse error = \(error)")
                    XCTAssert(false, "no result from service")
                }
            case .failure(let error):
                print("request error = \(error)")
                XCTAssert(false, "no result from service")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
}
