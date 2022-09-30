import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    private typealias ImageDataPresentationAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(
            viewModel.feed.map { model in
                let adapter = ImageDataPresentationAdapter(model: model, imageLoader: imageLoader)
                
                let view = FeedImageCellController(
                    viewModel: FeedImagePresenter.map(model),
                    delegate: adapter
                )
                
                adapter.presenter = LoadResourcePresenter(
                    resourceView: WeakRefVirtualProxy(view),
                    loadingView: WeakRefVirtualProxy(view),
                    errorView: WeakRefVirtualProxy(view),
                    mapper: { data in
                        guard let image = UIImage(data: data) else {
                            throw InvalidImageData()
                        }
                        return image
                    }
                )
                
                return view
            }
        )
    }
}

private struct InvalidImageData: Error {}
