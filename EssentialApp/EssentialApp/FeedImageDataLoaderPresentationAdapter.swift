import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: ResourceView>: FeedImageCellControllerDelegate {
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: LoadResourcePresenter<Data, View>?

    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoading()

        let model = self.model
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
//                        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                    }
                },
                receiveValue: { [weak self] data in
                    self?.presenter?.didFinishLoading(with: data)
                }
            )
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

final class LoadMorePresentationAdapter<View: ResourceView>: FeedImageCellControllerDelegate {
    private let model: Paginated<FeedImage>
    private var task: FeedImageDataLoaderTask?
    
    var presenter: LoadResourcePresenter<Paginated<FeedImage>, View>?
    
    init(model: Paginated<FeedImage>) {
        self.model = model
    }
    
    func didRequestImage() {
        presenter?.didStartLoading()
        
        model.loadMore? { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoading(with: data)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
