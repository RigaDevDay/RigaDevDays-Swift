//  Copyright © 2019 RigaDevDays. All rights reserved.

import XCTest
@testable import RigaDevDays

class SwissKnifeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTRUEIsValidEmailAddress() {
        XCTAssertTrue("email@server.com".isValidEmailAddress())
    }

    func testFALSEIsValidEmailAddress() {
        XCTAssertFalse("email@server".isValidEmailAddress())
    }
}
