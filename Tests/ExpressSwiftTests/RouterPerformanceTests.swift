@testable import ExpressSwift
import XCTest

public final class RouterPerformanceTests: XCTestCase {
  public func testCaseSensitivePerformance() throws {
    let router = Router()
    for letter in ["a", "b", "c", "d", "e", "f", "g"] {
      router.use(Route(stringLiteral: "/\(letter)/:\(letter)_id"), makeMiddleware { _, _ in
        return false
      })
    }

    measure {
      for _ in 0 ..< 100_00 {
        _ = router.handle(Request.makeSample(.GET, "/a/42"), Response.makeForUnitTests())
      }
    }
  }
}
