import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<Paginated<FeedImage>, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

public protocol CommentsLoader {
    typealias Result = Swift.Result<[ImageComment], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
