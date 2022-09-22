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
    public typealias SaveResult = FeedCache.Result
    // we need to notify clients of the save command when error occured and operation stopped
    // since operations are asynchronous we can pass a block/closure where..
    // we receive an error if anything went wrong

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] deletionResult in
            guard let self else { return }

            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
            case .failure(let cacheDeletionError):
                completion(.failure(cacheDeletionError))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal, timestamp: currentDate(), completion: { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(.none):
                completion(.success([]))
            case .success(let .some(cachedFeed)):
                if FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate()) {
                    completion(.success(cachedFeed.feed.toModels))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
            case .success(let .some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
            case .success:
                completion(.success(()))
            }
        }
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
