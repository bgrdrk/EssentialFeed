import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet { onChange?(self) }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading:
            return true
        case .pending, .loaded, .failed:
            return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed):
            return feed
        case .pending, .loading, .failed:
            return nil
        }
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}
