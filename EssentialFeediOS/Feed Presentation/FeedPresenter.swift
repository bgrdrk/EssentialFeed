import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var view: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.view?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
