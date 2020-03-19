import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let postsController = PostsController()
    try router.register(collection: postsController)

    let usersController = UsersController()
    try router.register(collection: usersController)

    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)

    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
}
