import Foundation

public protocol FeedStore {
    typealias RetrievalCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date,
                completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
