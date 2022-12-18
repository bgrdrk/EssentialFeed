import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: FeedImageDataLoader
    private let selection: (FeedImage) -> Void
    
    private typealias ImageDataPresentationAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>>
    
    init(
        controller: ListViewController?,
        imageLoader: FeedImageDataLoader,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter(
                model: model,
                imageLoader: imageLoader
            )
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                }
            )
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake
            )
            
            return CellController(id: model, view)
        }
        
        guard viewModel.loadMore != nil else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter<WeakRefVirtualProxyExtra<FeedViewAdapter>>(model: viewModel)
        let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.didRequestImage)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: WeakRefVirtualProxyExtra(self),
            loadingView: WeakRefVirtualProxy(loadMoreController),
            errorView: WeakRefVirtualProxy(loadMoreController)
        )
        
        let loadMoreSection = [CellController(id: UUID(), loadMoreController)]
        
        controller?.display(feed, loadMoreSection)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
