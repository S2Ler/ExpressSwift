import Foundation
import NIO
import NIOSSL

public extension Express {
  struct Config {
    public var numberOfThreads: Int
    public var maxMessagesPerRead: ChannelOptions.Types.MaxMessagesPerReadOption.Value
    public var recvAllocator: ChannelOptions.Types.RecvAllocatorOption.Value
    public var sslContext: NIOSSLContext?

    public init(numberOfThreads: Int,
                maxMessagesPerRead: ChannelOptions.Types.MaxMessagesPerReadOption.Value,
                recvAllocator: ChannelOptions.Types.RecvAllocatorOption.Value,
                sslContext: NIOSSLContext? = nil) {
      self.numberOfThreads = numberOfThreads
      self.maxMessagesPerRead = maxMessagesPerRead
      self.recvAllocator = recvAllocator
      self.sslContext = sslContext
    }

    public static var `default`: Config {
      return Config(numberOfThreads: 1,
                    maxMessagesPerRead: 1,
                    recvAllocator: AdaptiveRecvByteBufferAllocator(),
                    sslContext: nil)
    }
  }
}
