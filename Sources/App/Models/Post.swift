import FluentMySQL
import Vapor

/// A single entry of a Post list.
final class Post: MySQLUUIDModel {

    var id: UUID?
    var title: String
    var summary: String
    var content: String
    var slug: String
    var published: String
    var publishedAt: Date?
    var imageUrl: String?
    var fluentCreatedAt: Date?
    var fluentUpdatedAt: Date?
    var userId: User.ID

    internal init(title: String, summary: String, content: String, slug: String, published: String, publishedAt: Date?, imageUrl: String?, fluentCreatedAt: Date?, fluentUpdatedAt: Date?, userId: User.ID) {
        self.title = title
        self.summary = summary
        self.content = content
        self.slug = slug
        self.published = published
        self.publishedAt = publishedAt
        self.imageUrl = imageUrl
        self.fluentCreatedAt = fluentCreatedAt
        self.fluentUpdatedAt = fluentUpdatedAt
        self.userId = userId
    }

    struct PostForm: Content {
        var title: String
        var summary: String
        var content: String
        var slug: String
        var published: String
        var publishedAt: Date?
        var imageUrl: String?
        var userId: UUID
    }
}

extension Post {
    var user: Parent<Post, User> {
        return parent(\.userId)
    }

    var categories: Siblings<Post, Category, PostCategoryPivot> {
      return siblings()
    }
}

extension Post: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
      return Database.create(self, on: connection) { builder in
        try addProperties(to: builder)
        builder.reference(from: \.userId, to: \User.id)
      }
    }
}

extension Post: Parameter { }
extension Post: Content { }
