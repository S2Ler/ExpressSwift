import Foundation
import Logging
import NIO
import NIOHTTP1

internal final class HTTPHandler: ChannelInboundHandler {
  private enum HTTPClientState {
    case ready
    case parsingBody(HTTPRequestHead, Data?)
  }

  typealias InboundIn = HTTPServerRequestPart

  private let router: Router
  private var state: HTTPClientState
  private let logger: Logger

  init(router: Router) {
    state = .ready
    self.router = router
    logger = Logger(label: "HTTPHandler")
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let request = unwrapInboundIn(data)

    switch request {
    case .head(let head):
      switch state {
      case .ready: state = .parsingBody(head, nil)
      case .parsingBody: assert(false, "Unexptected HTTPClientResponsePart.head when body being parsed")
      }
    case .body(var body):
      switch state {
      case .ready: assert(false, "Unexpected HTTPClientResponse.body when awaiting request head")
      case .parsingBody(let head, let existingData):
        let data: Data
        if var existing = existingData {
          existing += Data(body.readBytes(length: body.readableBytes) ?? [])
          data = existing
        }
        else {
          data = Data(body.readBytes(length: body.readableBytes) ?? [])
        }
        state = .parsingBody(head, data)
      }

    case .end(let tailHeaders):
      assert(tailHeaders == nil, "Unexpected tail headers")
      switch state {
      case .ready: assert(false, "Unexpected HTTPClientResponse.end when awaiting request head")
      case .parsingBody(let head, let data):
        let request = Request(head: head, body: data)
        let response = Response(channel: context.channel)
        let shouldContinueHandling = router.handle(request, response)
        if shouldContinueHandling {
          response.status = .notFound
          response.send("")
        }
        state = .ready
      }
    }
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error) {
    logger.error("HTTPHandler error caught: \(error)")
    context.close(promise: nil)
  }
}
