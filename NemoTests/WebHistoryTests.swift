//
//  WebHistoryTests.swift
//  NemoTests
//
//  Created by Dushyant Bansal on 02/10/18.
//  Copyright © 2018 Dushyant Bansal. All rights reserved.
//

import XCTest
@testable import Nemo

class WebHistoryTests: XCTestCase {
  
  var webHistory: WebHistory!
  
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
      webHistory = WebHistory("test.data")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveAndFetchURL() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      let url = URL(string: "http://twitter.com")!
      webHistory.addURL(url)
      let urls = webHistory.searchForText("tw")
      XCTAssertTrue(urls.count == 1)
      XCTAssertEqual(urls[0], url)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
