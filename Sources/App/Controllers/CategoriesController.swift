//
//  CategoriesController.swift
//  App
//
//  Created by Fitzgerald Afful on 19/03/2020.
//

import Foundation
import Vapor

struct CategoriesController: RouteCollection {
  func boot(router: Router) throws {
    let categoriesRoute = router.grouped("api", "categories")
    categoriesRoute.post(Category.self, use: createHandler)
    categoriesRoute.get(use: getAllHandler)
    categoriesRoute.get(Category.parameter, use: getHandler)
    categoriesRoute.get(Category.parameter, "posts", use: getPostsHandler)
  }

  func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
    return category.save(on: req)
  }

  func getAllHandler(_ req: Request) throws -> Future<[Category]> {
    return Category.query(on: req).all()
  }

  func getHandler(_ req: Request) throws -> Future<Category> {
    return try req.parameters.next(Category.self)
  }

  func getPostsHandler(_ req: Request) throws -> Future<[Post]> {
    return try req.parameters.next(Category.self).flatMap(to: [Post].self) { category in
      try category.posts.query(on: req).all()
    }
  }
}
