import Foundation

/// Returns if handling should continue
public typealias HandleFunc = (_ request: Request, _ response: Response) -> Bool

public protocol Middleware {
  /// Returns if handling should continue
  func handle(_ request: Request,
              _ response: Response) -> Bool
}

public func makeMiddleware(_ handleFunc: @escaping HandleFunc) -> Middleware {
  class MiddlewareFunc: Middleware {
    private let _handle: HandleFunc
    init(_ handle: @escaping HandleFunc) {
      _handle = handle
    }

    func handle(_ request: Request, _ response: Response) -> Bool {
      return _handle(request, response)
    }
  }

  return MiddlewareFunc(handleFunc)
}
