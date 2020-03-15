import FluentMySQL
import Vapor

/// A single entry of a Todo list.
final class User: Content {

    var id: UUID?
    var firstName: String
    var lastName: String
    var email: String
    var passwordHash: String
    var registeredAt: String
    var lastLogin: String


    init(firstName: String, lastName: String, email: String, passwordHash: String, registeredAt: String, lastLogin: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email =  email
        self.passwordHash = passwordHash
        self.registeredAt = registeredAt
        self.lastLogin = lastLogin
    }
}

extension User {
    var posts: Children<User, Post> {
        return children(\.userId)
    }
}

extension User: MySQLUUIDModel {}
extension User: Migration { }
extension User: Parameter { }
