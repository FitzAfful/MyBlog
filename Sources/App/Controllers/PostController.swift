import Vapor

/// Controls basic CRUD operations on `User`s.
final class PostController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Post> {
        return try req.content.decode(Post.PostForm.self).flatMap { postForm in
            return User.find(postForm.userId, on: req).flatMap { user in
                guard let userId = try user?.requireID() else {
                    throw Abort(.badRequest)
                }

                let post = Post(title: postForm.title, summary: postForm.summary, content: postForm.content, slug: postForm.slug, published: postForm.published, publishedAt: nil, imageUrl: postForm.imageUrl, fluentCreatedAt: Date(), fluentUpdatedAt: Date(), userId: userId)

                return post.save(on: req)
            }
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
        }.transform(to: .ok)
    }
}
