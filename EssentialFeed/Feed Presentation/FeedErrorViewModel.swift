public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
