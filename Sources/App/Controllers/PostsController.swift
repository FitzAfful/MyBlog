import Vapor

/// Controls basic CRUD operations on `User`s.
final class PostsController : RouteCollection{
    func boot(router: Router) throws {
      let postsRoutes = router.grouped("api", "posts")
      postsRoutes.get(use: getAllHandler)
      postsRoutes.post(Post.self, use: createHandler)
      postsRoutes.get(Post.parameter, use: getHandler)
      postsRoutes.put(Post.parameter, use: updateHandler)
      postsRoutes.delete(Post.parameter, use: deleteHandler)
      postsRoutes.get("first", use: getFirstHandler)
      postsRoutes.get("sorted", use: sortedHandler)
      postsRoutes.get(Post.parameter, "user", use: getUserHandler)
      postsRoutes.post(Post.parameter, "categories", Category.parameter, use: addCategoriesHandler)
      postsRoutes.get(Post.parameter, "categories", use: getCategoriesHandler)
      postsRoutes.delete(Post.parameter, "categories", Category.parameter, use: removeCategoriesHandler)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Post]> {
      return Post.query(on: req).all()
    }

    func createHandler(_ req: Request, post: Post) throws -> Future<Post> {
      return post.save(on: req)
    }

    func getHandler(_ req: Request) throws -> Future<Post> {
      return try req.parameters.next(Post.self)
    }

    func updateHandler(_ req: Request) throws -> Future<Post> {
      return try flatMap(to: Post.self,
                         req.parameters.next(Post.self),
                         req.content.decode(Post.self)) { post, updatedPost in
                            post.title = updatedPost.title
                            post.summary = updatedPost.summary
                            post.content = updatedPost.content
                            post.published = updatedPost.published
                            post.publishedAt = updatedPost.publishedAt
                            post.slug = updatedPost.slug
                            post.imageUrl = updatedPost.imageUrl
        post.fluentUpdatedAt = Date()
        return post.save(on: req)
      }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
      return try req.parameters.next(Post.self).delete(on: req).transform(to: .noContent)
    }

    func getFirstHandler(_ req: Request) throws -> Future<Post> {
      return Post.query(on: req).first().unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).sort(\.publishedAt, .ascending).all()
    }

    func getUserHandler(_ req: Request) throws -> Future<User> {
      return try req.parameters.next(Post.self).flatMap(to: User.self) { post in
        post.user.get(on: req)
      }
    }

    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
      return try flatMap(to: HTTPStatus.self, req.parameters.next(Post.self),
                         req.parameters.next(Category.self)) { post, category in
        return post.categories.attach(category, on: req).transform(to: .created)
      }
    }

    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
      return try req.parameters.next(Post.self).flatMap(to: [Category].self) { post in
        try post.categories.query(on: req).all()
      }
    }

    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
      return try flatMap(to: HTTPStatus.self, req.parameters.next(Post.self),
                         req.parameters.next(Category.self)) { post, category in
        return post.categories.detach(category, on: req).transform(to: .noContent)
      }
    }
}
