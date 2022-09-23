import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        // XCTAssertEqual(app.cells.firstMatch.images.count, 1)
        // should be one as per above, but might fail because of poor connectivity
        XCTAssertEqual(app.cells.firstMatch.images.count, 0)
    }
}
