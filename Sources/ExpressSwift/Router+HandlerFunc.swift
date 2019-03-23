import Foundation
import NIOHTTP1

public extension Router {
  func use(_ route: Route, _ handler: @escaping HandleFunc) {
    use(route, makeMiddleware(handler))
  }

  func method(_ httpMethod: HTTPMethod, _ handler: @escaping HandleFunc) {
    method(httpMethod, makeMiddleware(handler))
  }

  func use(_ route: Route, _ method: HTTPMethod, _ handler: @escaping HandleFunc) {
    use(route, method, makeMiddleware(handler))
  }

  func all(_ handler: @escaping HandleFunc) {
    all(makeMiddleware(handler))
  }
}
