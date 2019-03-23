import Foundation
import NIO
import NIOHTTP1

public class Response {
  public var status = HTTPResponseStatus.ok
  public var headers = HTTPHeaders()

  public let channel: Channel
  private var isHeadSent = false
  private var didEnd = false

  public init(channel: Channel) {
    self.channel = channel
  }

  public static func makeForUnitTests() -> Response {
    return Response(channel: EmbeddedChannel())
  }

  @discardableResult
  public func send(_ string: String) -> EventLoopFuture<Void> {
    sendHead()
    guard !didEnd else { return channel.eventLoop.makeSucceededFuture(()) }

    let utf8 = string.utf8
    var buffer = channel.allocator.buffer(capacity: utf8.count)
    buffer.writeBytes(utf8)

    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))

    return channel
      .writeAndFlush(part)
      .recover(handleError)
      .map(end)
  }

  func sendHead() {
    guard !isHeadSent else { return }
    isHeadSent = true

    let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
    let part = HTTPServerResponsePart.head(head)
    _ = channel.writeAndFlush(part).recover(handleError)
  }

  func handleError(_: Error) {
    end()
  }

  func end() {
    guard !didEnd else { return }
    didEnd = true

    let endPart = HTTPServerResponsePart.end(nil)
    _ = channel
      .writeAndFlush(endPart)
      .map { self.channel.close() }
  }
}

public extension Response {
  subscript(name: String) -> String? {
    set {
      assert(!isHeadSent, "Header has been sent")
      if let v = newValue {
        headers.replaceOrAdd(name: name, value: v)
      }
      else {
        headers.remove(name: name)
      }
    }
    get {
      return headers[name].joined(separator: ", ")
    }
  }
}

public extension Response {
  func send<S: Collection>(bytes: S) where S.Element == UInt8 {
    sendHead()
    guard !didEnd else { return }

    var buffer = channel.allocator.buffer(capacity: bytes.count)
    buffer.writeBytes(bytes)

    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))

    _ = channel.writeAndFlush(part)
      .recover(handleError)
      .map { self.end() }
  }
}

public extension Response {
  func json<T: Encodable>(_ model: T) {
    let data: Data
    do {
      data = try JSONEncoder().encode(model)
    }
    catch {
      return handleError(error)
    }

    self["Content-Type"] = "application/json"
    self["Content-Length"] = "\(data.count)"

    sendHead()
    guard !didEnd else { return }

    var buffer = channel.allocator.buffer(capacity: data.count)
    buffer.writeBytes(data)
    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))

    _ = channel.writeAndFlush(part)
      .recover(handleError)
      .map { self.end() }
  }
}
