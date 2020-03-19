
import Vapor
import FluentMySQL

final class Category: Codable {
  var id: Int?
  var name: String

  init(name: String) {
    self.name = name
  }
}

extension Category: MySQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

extension Category {
  var posts: Siblings<Category, Post, PostCategoryPivot> {
    return siblings()
  }
}
