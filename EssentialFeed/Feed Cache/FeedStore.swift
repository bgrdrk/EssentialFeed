import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date,
                completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
