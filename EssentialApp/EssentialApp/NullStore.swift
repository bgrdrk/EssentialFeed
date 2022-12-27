import Foundation
import EssentialFeed

class NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}

extension NullStore: FeedStore {
    func deleteCachedFeed() throws {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    func retrieve() throws -> CachedFeed? { .none }
}
