import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static let OK_200 = 200

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = root(from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }

    private static func root(from data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
}
