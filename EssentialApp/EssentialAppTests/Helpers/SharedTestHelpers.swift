import Foundation
import EssentialFeed

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyData: Data {
    Data("any data".utf8)
}

var anyURL: URL {
    URL(string: "http://a-url.com")!
}

var uniqueFeed: [FeedImage] {
    [
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL),
    ]
}