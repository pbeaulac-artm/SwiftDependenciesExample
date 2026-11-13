//
//  SwiftDependenciesExampleUITests.swift
//  SwiftDependenciesExampleUITests
//
//  Created by Pascale Beaulac on 2026-11-12.
//

import XCTest

final class SwiftDependenciesExampleUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAllIpsumFeaturesLoadFromTheRootList() throws {
        let app = XCUIApplication()
        app.launch()

        let examples = [
            ("Lorem Ipsum", "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
            ("Beer Ipsum", "Amber malt, golden hops. A bright lager meets a toasted barley finish."),
            ("Coffee Ipsum", "Espresso crema, roasted beans. A quiet morning begins with a warm cup."),
            ("Space Ipsum", "Orbit ipsum, nebula shimmer. A small probe follows the light of distant stars."),
            ("Pirate Ipsum", "Ahoy ipsum! Hoist the canvas and follow the gulls beyond the harbour.")
        ]
        for (title, paragraph) in examples {
            let row = app.buttons[title]
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts[paragraph].waitForExistence(timeout: 5))
            app.navigationBars.buttons.firstMatch.tap()
            XCTAssertTrue(app.navigationBars["Swift Dependencies Ipsum"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testDeepLinksSelectParagraphsAtColdAndWarmStart() throws {
        let app = XCUIApplication()
        app.terminate()
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/beer/3")))
        let beer = app.staticTexts["A velvet porter pours slowly; roasted grain and caramel fill the glass."]
        XCTAssertTrue(beer.waitForExistence(timeout: 10))
        XCTAssertTrue(beer.isHittable)
        XCTAssertTrue(beer.isSelected)

        let examples = [
            ("lorem", "Lorem Ipsum", "Nullam fermentum lorem, quis tincidunt ipsum, vitae volutpat dolor."),
            ("coffee", "Coffee Ipsum", "A little latte, a long conversation, and the scent of toasted coffee."),
            ("space", "Space Ipsum", "Beyond the asteroid belt, a blue planet shines against the cosmic night."),
            ("pirate", "Pirate Ipsum", "Land ahead, matey! Drop the anchor and bring the treasure map ashore.")
        ]
        for (style, title, text) in examples {
            XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/\(style)/3")))
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
            let paragraph = app.staticTexts[text]
            XCTAssertTrue(paragraph.waitForExistence(timeout: 5))
            XCTAssertTrue(paragraph.isHittable)
            XCTAssertTrue(paragraph.isSelected)
        }

        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/pirate/0")))
        let first = app.staticTexts["Ahoy ipsum! Hoist the canvas and follow the gulls beyond the harbour."]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Swift Dependencies Ipsum"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeepLinkScrollsToParagraphBeyondVisibleRows() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.buttons["Beer Ipsum"].tap()
        let last = app.staticTexts["A velvet porter pours slowly; roasted grain and caramel fill the glass."]
        XCTAssertTrue(app.navigationBars["Beer Ipsum"].waitForExistence(timeout: 5))
        XCTAssertFalse(last.isHittable)

        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/beer/3")))
        XCTAssertTrue(last.waitForExistence(timeout: 5))
        XCTAssertTrue(last.isHittable)
        XCTAssertTrue(last.isSelected)
    }

    @MainActor
    func testFeatureOnlyAndInvalidDeepLinksPreserveNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/coffee")))
        let paragraph = app.staticTexts["Espresso crema, roasted beans. A quiet morning begins with a warm cup."]
        XCTAssertTrue(paragraph.waitForExistence(timeout: 5))
        XCTAssertFalse(paragraph.isSelected)

        for path in ["beer/99", "unknown", "beer/0/extra"] {
            XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "swiftdependenciesexample://ipsum/\(path)")))
            XCTAssertTrue(app.alerts["Unable to open link"].waitForExistence(timeout: 5))
            app.alerts.buttons["OK"].tap()
            XCTAssertTrue(app.navigationBars["Coffee Ipsum"].exists)
            XCTAssertTrue(paragraph.exists)
        }
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Swift Dependencies Ipsum"].waitForExistence(timeout: 5))
        app.buttons["Beer Ipsum"].tap()
        XCTAssertTrue(app.navigationBars["Beer Ipsum"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
