import Vapor
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UsersController: RouteCollection {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }

    /// Saves a decoded `User` to the database.
    func create(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { user in
            return user.save(on: req)
        }
    }

    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
        }.transform(to: .ok)
    }

    func boot(router: Router) throws {
      let usersRoute = router.grouped("api", "users")
      usersRoute.post(User.self, use: createHandler)
      usersRoute.get(use: getAllHandler)
      usersRoute.get(User.parameter, use: getHandler)
      usersRoute.get(User.parameter, "posts", use: getPostsHandler)
    }

    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap({ (user) in
            user.passwordHash = try BCrypt.hash(user.passwordHash)
            return user.save(on: req).toPublic()
        })
    }

    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }

    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }

    func getPostsHandler(_ req: Request) throws -> Future<[Post]> {
      return try req.parameters.next(User.self).flatMap(to: [Post].self) { user in
        try user.posts.query(on: req).all()
      }
    }
}
