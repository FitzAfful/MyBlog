import Vapor
import Leaf

/// Controls basic CRUD operations on `User`s.
final class WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("posts", Post.parameter, use: postHandler)
        router.get("users", User.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
        router.get("categories", use: allCategoriesHandler)
        router.get("categories", Category.parameter, use: categoryHandler)
        router.get("posts", "create", use: createPostHandler)
        router.post(Post.self, at: "posts", "create", use: createPostPostHandler)
        router.get("posts", Post.parameter, "edit", use: editPostHandler)
        router.post("posts", Post.parameter, "edit", use: editPostPostHandler)
        router.post("posts", Post.parameter, "delete", use: deletePostHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        return Post.query(on: req).all().flatMap(to: View.self) { posts in
            let context = IndexContext(title: "Home page", posts: posts)
            return try req.view().render("index", context)
        }
    }

    func postHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Post.self).flatMap(to: View.self) { post in
            return post.user.get(on: req).flatMap(to: View.self) { user in
                let context = PostContext(title: post.title, post: post, user: user)
                return try req.view().render("post", context)
            }
        }
    }

    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            return try user.posts.query(on: req).all().flatMap(to: View.self) { posts in
                let context = UserContext(title: user.firstName + " " + user.lastName, user: user, posts: posts)
                return try req.view().render("user", context)
            }
        }
    }

    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = AllUsersContext(title: "All Users", users: users)
            return try req.view().render("allUsers", context)
        }
    }

    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        let categories = Category.query(on: req).all()
        let context = AllCategoriesContext(categories: categories)
        return try req.view().render("allCategories", context)
    }

    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            let posts = try category.posts.query(on: req).all()
            let context = CategoryContext(title: category.name, category: category, posts: posts)
            return try req.view().render("category", context)
        }
    }

    func createPostHandler(_ req: Request) throws -> Future<View> {
        let context = CreatePostContext(users: User.query(on: req).all())
        return try req.view().render("createPost", context)
    }

    func createPostPostHandler(_ req: Request, post: Post) throws -> Future<Response> {
        return post.save(on: req).map(to: Response.self) { post in
            guard let id = post.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/posts/\(id)")
        }
    }

    func editPostHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Post.self).flatMap(to: View.self) { post in
            let context = EditPostContext(post: post, users: User.query(on: req).all())
            return try req.view().render("createPost", context)
        }
    }

    func editPostPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self,
                           req.parameters.next(Post.self),
                           req.content.decode(Post.self)) { post, data in
                            post.title = data.title
                            post.summary = data.summary
                            post.content = data.content
                            post.published = data.published
                            post.publishedAt = data.publishedAt
                            post.slug = data.slug
                            post.imageUrl = data.imageUrl
                            guard let id = post.id else {
                                throw Abort(.internalServerError)
                            }
                            let redirect = req.redirect(to: "/posts/\(id)")
                            return post.save(on: req).transform(to: redirect)
        }
    }

    func deletePostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Post.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }
}

struct IndexContext: Encodable {
    let title: String
    let posts: [Post]
}

struct PostContext: Encodable {
    let title: String
    let post: Post
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let posts: [Post]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    let title = "All Categories"
    let categories: Future<[Category]>
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let posts: Future<[Post]>
}

struct CreatePostContext: Encodable {
    let title = "Create An Post"
    let users: Future<[User]>
}

struct EditPostContext: Encodable {
    let title = "Edit Post"
    let post: Post
    let users: Future<[User]>
    let editing = true
}
