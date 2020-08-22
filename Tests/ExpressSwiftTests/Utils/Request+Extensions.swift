import ExpressSwift
import Foundation
import NIO
import NIOHTTP1

extension Request {
  static func makeSample(
    _ method: HTTPMethod,
    _ partialUri: String,
    body: Data? = nil,
    localAddress: SocketAddress? = nil,
    remoteAddress: SocketAddress? = nil) -> Request {
    return Request(head: HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1),
                                         method: method,
                                         uri: "http://localhost\(partialUri)"),
                   body: body,
                   localAddress: localAddress,
                   remoteAddress: remoteAddress)    
  }
}
