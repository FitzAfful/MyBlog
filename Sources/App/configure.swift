import FluentMySQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    try services.register(LeafProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let serverConfigure = NIOServerConfig.default(hostname: "127.0.0.1", port: 9090)
    services.register(serverConfigure)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    try services.register(FluentMySQLProvider())  // changed
    var databases = DatabasesConfig()
    let mysqlConfig = MySQLDatabaseConfig(
      hostname: "127.0.0.1",
      port: 3306,
      username: "root",
      password: "root",
      database: "myblog_db",
      transport: MySQLTransportConfig.unverifiedTLS
    )
    databases.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Post.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: PostCategoryPivot.self, database: .mysql)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
