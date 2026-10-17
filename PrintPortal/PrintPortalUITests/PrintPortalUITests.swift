//
//  PrintPortalUITests.swift
//  PrintPortalUITests
//
//  Created by Hafsa Faleel on 2026-10-11.
//
import XCTest

final class PrintPortalUITests: XCTestCase {

    override func setUpWithError() throws {
        // Stop immediately when a failure occurs so it's easier to debug
        continueAfterFailure = false
    }

    func testCatalogueScreenLoadsCorrectly() throws {
        // UI tests must launch the application
        let app = XCUIApplication()
        app.launch()

        // 1. Verify the Search Bar placeholder text exists
        let searchField = app.textFields["Search products..."]
        XCTAssertTrue(searchField.exists, "The search bar should be visible on the Catalogue screen.")

        // 2. Verify the Featured Products heading exists
        let sectionTitle = app.staticTexts["Featured Products"]
        XCTAssertTrue(sectionTitle.exists, "The Featured Products section title should be visible.")
    }
    
    func testFullUserJourneyNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Verify Catalogue loads first
        let searchField = app.textFields["Search products..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "App should start on the Catalogue.")

        // 2. Tap the first product card in the grid
        // NavigationLinks inside ScrollViews are treated as buttons in Xcode UI Tests
        let firstProductCard = app.scrollViews.buttons.firstMatch
        XCTAssertTrue(firstProductCard.exists, "There should be at least one product card to tap.")
        firstProductCard.tap()

        // 3. Verify we successfully navigated to the ProductDetailsView
        // We do this by checking if the native iOS "Back" button appeared in the top left
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "The app should navigate to the Product Details screen, displaying a back button.")

        // 4. Navigate back to the Catalogue
        backButton.tap()
        XCTAssertTrue(searchField.exists, "App should successfully navigate back to the main Catalogue.")

        // 5. Test the Tab Bar (If you have a "Projects" or "Favorites" tab at the bottom)
        // Note: Change "Projects" to match whatever text is on your actual tab bar button!
        let projectsTab = app.tabBars.buttons["Projects"]
        if projectsTab.exists {
            projectsTab.tap()
            XCTAssertTrue(projectsTab.isSelected, "The user should be able to switch to the Projects tab.")
        }
    }
}
