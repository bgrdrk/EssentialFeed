import Foundation

public final class LocalFeedLoader {

    let store: FeedStore
    /*
     Instructor comment: Safe choice is to inject this current date to LocalFeedLoader
     and not let the LocalFeedLoader to come up with it's Date. "protocol DateProvider" could be the example.
     Another option - closure - moving the responsibility to a collaborator (a simple closure in this case)
     and inject it as a dependency. Then we can easily control the current date/time during tests.
     */
    let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal, timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    
    public func load() throws -> [FeedImage] {
        if let cache = try store.retrieve(),
           FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.feed.toModels
        }
        return []
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        completion(ValidationResult {
            do {
                if let cache = try store.retrieve(),
                   !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    throw InvalidCache()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

private extension Array where Element == FeedImage {
    var toLocal: [LocalFeedImage] {
        map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    var toModels: [FeedImage] {
        map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
