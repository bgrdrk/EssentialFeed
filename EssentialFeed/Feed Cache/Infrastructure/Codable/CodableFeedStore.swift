import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    struct InvalidPath: Error {}
    
    public func retrieve() throws -> CachedFeed? {
        let storeURL = self.storeURL
            guard let data = try? Data(contentsOf: storeURL) else {
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
            } catch {
                throw error
            }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let storeURL = self.storeURL
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
            } catch {
                throw error
            }
    }

    public func deleteCachedFeed() throws {
        let storeURL = self.storeURL
        
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
        } catch {
            throw error
        }
    }
}
