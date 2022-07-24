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

    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private let maxCacheAgeInDays = 7
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

extension LocalFeedLoader {
    // we need to notify clients of the save command when error occured and operation stopped
    // since operations are asynchronous we can pass a block/closure where..
    // we receive an error if anything went wrong
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal, timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

extension LocalFeedLoader {
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .empty:
                completion(.success([]))
            case .found(let feed, let timestamp):
                if self.validate(timestamp) {
                    completion(.success(feed.toModels))
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
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case .found(_, let timestamp):
                if !self.validate(timestamp) {
                    self.store.deleteCachedFeed { _ in }
                }
            case .empty:
                break
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
