import Foundation

import NIOHTTP1

public class Request {
  public let head: HTTPRequestHead
  public let body: Data?
  public var userInfo = [String: Any]()

  public var path: Path
  public let query: [URLQueryItem]?
  internal var parameters: [String: String] = [:]

  public init(head: HTTPRequestHead, body: Data?) {
    self.head = head
    self.body = body

    let urlComponents = URLComponents(string: head.uri)!

    path = Path(urlComponents.path)
    query = urlComponents.queryItems
  }

  public func getParameter<T: LosslessStringConvertible>(_ parameter: String) -> T? {
    guard let stringParameter = parameters[parameter] else {
      return nil
    }

    return T(stringParameter)
  }
}

extension Request {
  public func json<T: Decodable>(_ type: T.Type) throws -> T? {
    guard let body = body else { return nil }
    let decoder = JSONDecoder()
    return try decoder.decode(type, from: body)
  }
}
