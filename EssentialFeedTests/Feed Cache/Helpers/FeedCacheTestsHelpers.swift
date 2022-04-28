import Foundation
import EssentialFeed

var uniqueImage: FeedImage {
    FeedImage(id: UUID(), description: "description", location: "location", url: anyURL)
}

var uniqueImageFeed: (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage, uniqueImage]
    let local = models.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (models, local)
}

extension Date {
    var minusFeedCacheMaxAge: Date {
        adding(days: -feedCacheMaxAgeInDays)
    }

    private var feedCacheMaxAgeInDays: Int {
        7
    }

    func adding(days: Int) -> Self {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Self {
        self + seconds
    }
}
