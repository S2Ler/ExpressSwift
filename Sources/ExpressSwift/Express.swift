import Logging
import NIO
import NIOHTTP1

open class Express: Router {
  private let config: Config
  private let eventLoopGroup: MultiThreadedEventLoopGroup
  private let logger = Logger(label: "ExpressSwift")

  public init(config: Config) {
    self.config = config
    eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: config.numberOfThreads)
    super.init()
  }

  private func createServerBootstrap(_ backlog: Int) -> ServerBootstrap {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let bootstrap = ServerBootstrap(group: eventLoopGroup)
      .serverChannelOption(ChannelOptions.backlog, value: Int32(backlog))
      .serverChannelOption(reuseAddrOpt, value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().flatMap { _ in
          channel.pipeline.addHandler(HTTPHandler(router: self))
        }
      }
      .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(reuseAddrOpt, value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead, value: config.maxMessagesPerRead)
      .childChannelOption(ChannelOptions.recvAllocator, value: config.recvAllocator)
    return bootstrap
  }

  open func listen(unixSocket: String = "express.socket", backlog: Int = 256) {
    let bootstrap = createServerBootstrap(backlog)

    do {
      let serverChannel = try bootstrap.bind(unixDomainSocketPath: unixSocket).wait()
      logger.info("Server running on: \(unixSocket)")

      try serverChannel.closeFuture.wait() // runs forever
    }
    catch {
      fatalError("Failed to start server with error: \(error)")
    }
  }

  open func listen(_ port: Int = 1337,
                   _ host: String = "localhost",
                   _ backlog: Int = 256) {
    let bootstrap = createServerBootstrap(backlog)

    do {
      let serverChannel = try bootstrap.bind(host: host, port: port).wait()
      if let localAddress = serverChannel.localAddress {
        logger.info("Server running on: \(localAddress)")
      }
      else {
        logger.info("Server running on: \(host):\(port)")
      }

      try serverChannel.closeFuture.wait() // runs forever
    }
    catch {
      fatalError("Failed to start server: \(error)")
    }
  }
}
