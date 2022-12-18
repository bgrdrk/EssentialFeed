import Foundation

public final class FeedItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Paginated<FeedImage> {
        guard response.isOK, let root = root(from: data) else {
            throw Error.invalidData
        }

        return .init(items: root.images)
    }

    private static func root(from data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
}
