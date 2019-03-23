import Foundation
import NIOHTTP1

open class Router {
  private var layers: [Layer] = []

  public init() {}

  public func use(_ route: Route, _ router: Router) {
    layers.append(Layer(kind: .router(route), middleware: router))
  }

  public func use(_ route: Route, _ middleware: Middleware) {
    if let router = middleware as? Router {
      use(route, router)
    }
    else {
      layers.append(Layer(kind: .route(route), middleware: middleware))
    }
  }

  public func method(_ method: HTTPMethod, _ middleware: Middleware) {
    let layer = Layer(kind: .method(method), middleware: middleware)
    layers.append(layer)
  }

  public func use(_ route: Route, _ method: HTTPMethod, _ middleware: Middleware) {
    let layer = Layer(kind: .routeWithMethod(route, method), middleware: middleware)
    layers.append(layer)
  }

  public func all(_ middleware: Middleware) {
    let layer = Layer(kind: .all, middleware: middleware)
    layers.append(layer)
  }
}

extension Router: Middleware {
  public func handle(_ request: Request, _ response: Response) -> Bool {
    var removedPathComponent: Path?
    for offset in 0..<layers.count {
      if let pathComponentToRestore = removedPathComponent {
        request.path.restoreLeadingComponent(pathComponentToRestore)
        removedPathComponent = nil
      }

      let layer = layers[offset]
      var parameters: [String: String] = [:]
      if layer.canHandle(request, parameters: &parameters) {
        if case .router(let routerRoute) = layer.kind {
          removedPathComponent = request.path.removeLeadingRoute(routerRoute)
        }
        request.parameters.merge(parameters) { (_, rhsKey) -> String in
          rhsKey
        }
        let shouldContinueHandling = layer.handle(request, response)
        if !shouldContinueHandling {
          return false
        }
      }
    }
    return true
  }
}
