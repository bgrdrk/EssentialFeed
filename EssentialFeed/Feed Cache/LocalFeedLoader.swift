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

    // we need to notify clients of the save command when error occured and operation stopped
    // since operations are asynchronous we can pass a block/closure where..
    // we receive an error if anything went wrong
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}
