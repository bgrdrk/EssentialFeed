import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let root = root(from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }

    private static func root(from data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
}
