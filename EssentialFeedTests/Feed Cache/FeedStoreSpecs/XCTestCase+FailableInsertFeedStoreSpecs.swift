import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore,
                                                       file: StaticString = #file,
                                                       line: UInt = #line) {
        let feed = uniqueImageFeed.local
        let timestamp = Date()

        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore,
                                                          file: StaticString = #file,
                                                          line: UInt = #line) {
        let feed = uniqueImageFeed.local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
