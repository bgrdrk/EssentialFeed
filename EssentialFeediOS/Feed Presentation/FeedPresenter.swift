import EssentialFeed

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var view: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.view?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
