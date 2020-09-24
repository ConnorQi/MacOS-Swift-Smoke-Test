//
//  mac_swift_release_testUITests.swift
//  mac-swift-release-testUITests
//
//  Created by bys on 2019/8/27.
//  Copyright © 2019 bys. All rights reserved.
//

import XCTest

class mac_swift_release_testUITests: XCUITestBase {

    func testEvent() {
        let button = app.buttons["evewithproperties"]
        if button.exists {
            button.tap()
            XCTAssert(button.isSelected, "Tap Success")
        }
    }

}
