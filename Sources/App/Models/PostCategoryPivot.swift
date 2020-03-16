
import FluentMySQL
import Foundation

final class PostCategoryPivot: MySQLUUIDPivot {

  var id: UUID?
  var postID: Post.ID
  var categoryID: Category.ID

  typealias Left = Post
  typealias Right = Category
  static let leftIDKey: LeftIDKey = \.postID
  static let rightIDKey: RightIDKey = \.categoryID

  init(_ post: Post, _ category: Category) throws {
    self.postID = try post.requireID()
    self.categoryID = try category.requireID()
  }
}


extension PostCategoryPivot: ModifiablePivot {}

extension PostCategoryPivot: Migration {
  static func prepare(on connection: MySQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.postID, to: \Post.id, onDelete: .cascade)
      builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
    }
  }
}
