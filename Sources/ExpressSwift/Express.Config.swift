import Foundation
import NIO

public extension Express {
  struct Config {
    public var numberOfThreads: Int
    public var maxMessagesPerRead: MaxMessagesPerReadOption.Value
    public var recvAllocator: RecvAllocatorOption.Value

    public init(numberOfThreads: Int,
                maxMessagesPerRead: MaxMessagesPerReadOption.Value,
                recvAllocator: RecvAllocatorOption.Value) {
      self.numberOfThreads = numberOfThreads
      self.maxMessagesPerRead = maxMessagesPerRead
      self.recvAllocator = recvAllocator
    }

    public static var `default`: Config {
      return Config(numberOfThreads: 1,
                    maxMessagesPerRead: 1,
                    recvAllocator: AdaptiveRecvByteBufferAllocator())
    }
  }
}
