import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]

        var feedItems: [FeedItem] {
            items.map { $0.feedItem }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            .init(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    private static var OK_200: Int { 200 }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> [FeedItem]? {
        guard response.statusCode == OK_200 else {
            return nil
        }

        let root = try? JSONDecoder().decode(Root.self, from: data)

        return root?.items.map { $0.feedItem }
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }

        return .success(root.feedItems)
    }
}
