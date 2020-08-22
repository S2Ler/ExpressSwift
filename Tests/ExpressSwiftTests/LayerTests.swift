@testable import ExpressSwift
import NIOHTTP1
import XCTest

final class LayerTests: XCTestCase {
  func testLayerByMethod() {
    let layer = Layer(kind: .method(.GET), middleware: makeMiddleware { _, _ in
      return false
    })
    let getR = Request(head: .init(version: HTTPVersion(major: 1, minor: 1),
                                   method: .GET,
                                   uri: ""),
                       body: nil,
                       localAddress: nil,
                       remoteAddress: nil)
    let postR = Request(head: .init(version: HTTPVersion(major: 1, minor: 1),
                                    method: .POST,
                                    uri: ""),
                        body: nil,
                        localAddress: nil,
                        remoteAddress: nil)
    var parameters: [String: String] = [:]
    XCTAssertTrue(layer.canHandle(getR, parameters: &parameters))
    XCTAssertFalse(layer.canHandle(postR, parameters: &parameters))
  }

  func testLayerByPath() {
    let layer = Layer(kind: .route("/name"), middleware: makeMiddleware { _, _ in
      return false
    })

    let getRWithPath = Request(head: .init(version: HTTPVersion(major: 1, minor: 1),
                                           method: .GET,
                                           uri: "/name"),
                               body: nil,
                               localAddress: nil,
                               remoteAddress: nil)
    let getRWithoutPath = Request(head: .init(version: HTTPVersion(major: 1, minor: 1),
                                              method: .GET,
                                              uri: "/"),
                                  body: nil,
                                  localAddress: nil,
                                  remoteAddress: nil)
    let postR = Request(head: .init(version: HTTPVersion(major: 1, minor: 1),
                                    method: .POST,
                                    uri: ""),
                        body: nil,
                        localAddress: nil,
                        remoteAddress: nil)

    var parameters: [String: String] = [:]
    XCTAssertTrue(layer.canHandle(getRWithPath, parameters: &parameters))
    XCTAssertFalse(layer.canHandle(getRWithoutPath, parameters: &parameters))
    XCTAssertFalse(layer.canHandle(postR, parameters: &parameters))
  }
}
