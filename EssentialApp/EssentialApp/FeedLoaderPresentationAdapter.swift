import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    var presenter: LoadResourcePresenter<Paginated<FeedImage>, FeedViewAdapter>?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()

        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoading(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

final class CommentsPresentationAdapter {
    private let loader: CommentsLoader
    var presenter: LoadResourcePresenter<[ImageComment], CommentsViewAdapter>?
    
    init(loader: CommentsLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        loader.load { [weak self] result in
            switch result {
            case let .success(comments):
                self?.presenter?.didFinishLoading(with: comments)
                
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}
