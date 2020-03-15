import FluentMySQL
import Vapor

/// A single entry of a Todo list.
final class User: MySQLModel {

    var id: Int?
    var firstName: String
    var lastName: String
    var email: String
    var passwordHash: String
    var registeredAt: String
    var lastLogin: String


    init(id: Int? = nil, firstName: String, lastName: String, email: String, passwordHash: String, registeredAt: String, lastLogin: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email =  email
        self.passwordHash = passwordHash
        self.registeredAt = registeredAt
        self.lastLogin = lastLogin
    }
}

extension User: Migration { }
extension User: Content { }
extension User: Parameter { }
