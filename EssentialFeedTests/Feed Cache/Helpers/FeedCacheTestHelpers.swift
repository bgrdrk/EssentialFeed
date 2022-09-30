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
    private var feedCacheMaxAgeInDays: Int {
        7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        self.adding(days: -feedCacheMaxAgeInDays)
    }
}
