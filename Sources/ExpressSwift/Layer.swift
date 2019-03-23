import Foundation
import NIOHTTP1

internal class Layer {
  public enum Kind {
    case route(Route)
    case routeWithMethod(Route, HTTPMethod)
    case router(Route)
    case method(HTTPMethod)
    case all
  }

  public let kind: Kind
  public let middleware: Middleware

  public init(kind: Kind, middleware: Middleware) {
    self.kind = kind
    self.middleware = middleware
  }

  internal func canHandle(_ request: Request, parameters: inout [String: String]) -> Bool {
    switch kind {
    case .method(let method):
      return request.head.method == method
    case .route(let route):
      return route.matches(request.path, parameters: &parameters)
    case .router(let route):
      return route.matches(request.path, parameters: &parameters, partially: true)
    case .routeWithMethod(let route, let method):
      return route.matches(request.path, parameters: &parameters) && request.head.method == method
    case .all:
      return true
    }
  }
}

extension Layer: Middleware {
  func handle(_ request: Request, _ response: Response) -> Bool {
    return middleware.handle(request, response)
  }
}
