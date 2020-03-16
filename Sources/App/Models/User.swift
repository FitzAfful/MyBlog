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

    final class Public: Codable {
        var id: UUID?
        var firstName: String
        var lastName: String

        init(id: UUID?, firstName: String, lastName: String) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
        }
    }
}

extension User {
    func toPublic() -> User.Public {
        return User.Public(id: id, firstName: firstName, lastName: lastName)
    }
}

extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}


extension User.Public: Content {}

extension User {
    var posts: Children<User, Post> {
        return children(\.userId)
    }
}

extension User: MySQLUUIDModel {}
extension User: Migration { }
extension User: Parameter { }
