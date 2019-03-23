@testable import ExpressSwift
import NIOHTTP1
import XCTest

class RouterTests: XCTestCase {
  func testRouter() {
    let router = Router()
    var routerCalled = false
    router.method(.GET, makeMiddleware { _, _ in
      routerCalled = true
      return true
    })

    let req = Request.makeSample(.GET, "/")
    let res = Response.makeForUnitTests()
    let shouldContinueHandling = router.handle(req, res)

    XCTAssertTrue(routerCalled)
    XCTAssertTrue(shouldContinueHandling)
  }

  func testRouter2() {
    let router = Router()
    var routerCalled1Times = 0
    router.method(.GET, makeMiddleware { _, _ in
      routerCalled1Times += 1
      return true
    })

    var routerCalled2Times = 0
    router.method(.POST, makeMiddleware { _, _ in
      routerCalled2Times += 1
      return true
    })

    let reqGet = Request.makeSample(.GET, "/")
    let reqPost = Request.makeSample(.POST, "/")
    let res = Response.makeForUnitTests()
    var finishedTimes = 0

    if router.handle(reqGet, res) {
      finishedTimes += 1
    }
    if router.handle(reqPost, res) {
      finishedTimes += 1
    }

    XCTAssertEqual(routerCalled1Times, 1)
    XCTAssertEqual(routerCalled2Times, 1)
    XCTAssertEqual(finishedTimes, 2)
  }

  func testInnerRouter() {
    let router = Router()
    var authCount1 = 0
    router.all(makeMiddleware { _, _ in
      authCount1 += 1
      return true
    })

    let todoRouter = Router()
    var todoCreatedCount = 0
    todoRouter.use("/", .POST, makeMiddleware { _, _ in
      todoCreatedCount += 1
      return false
    })

    var todoGotCount = 0
    todoRouter.use("/", .GET, makeMiddleware { _, _ in
      todoGotCount += 1
      return false
    })

    var todoAllCount = 0
    todoRouter.use("/all", makeMiddleware { _, _ in
      todoAllCount += 1
      return false
    })

    router.use("/todo", todoRouter)

    var todoPageCount = 0
    router.use("/todo/page", makeMiddleware { _, _ in
      todoPageCount += 1
      return false
    })

    let res = Response.makeForUnitTests()

    _ = router.handle(Request.makeSample(.GET, "/todo"), res)
    _ = router.handle(Request.makeSample(.POST, "/todo"), res)
    _ = router.handle(Request.makeSample(.GET, "/todo"), res)
    _ = router.handle(Request.makeSample(.POST, "/todo"), res)
    _ = router.handle(Request.makeSample(.POST, "/todo"), res)
    _ = router.handle(Request.makeSample(.GET, "/todo/all"), res)
    _ = router.handle(Request.makeSample(.GET, "/todo/page"), res)

    XCTAssertEqual(authCount1, 7)
    XCTAssertEqual(todoGotCount, 2)
    XCTAssertEqual(todoCreatedCount, 3)
    XCTAssertEqual(todoAllCount, 1)
    XCTAssertEqual(todoPageCount, 1)
  }

  func testWithParameters() {
    let router = Router()
    var called = false
    router.use("/todo/:id/new", makeMiddleware { request, _ in
      XCTAssertEqual(request.getParameter("id"), 100)
      called = true
      return false
    })

    _ = router.handle(Request.makeSample(.GET, "/todo/100/new"), Response.makeForUnitTests())

    XCTAssertTrue(called)
  }

  func testDeepRouter() {
    let router = Router()
    var topRouter = router
    var finalRoute: String = ""
    for i in 0..<10_000 {
      let newRouter = Router()
      newRouter.all { (_, _) in
        return true
      }
      let routeString = "/\(i)"
      let route = Route(stringLiteral: routeString)
      topRouter.use(route, newRouter)
      topRouter = newRouter
      finalRoute.append(routeString)
    }

    _ = router.handle(Request.makeSample(.GET, finalRoute), Response.makeForUnitTests())

    // The test shouldn't crash
  }

  func testWideRouter() {
    let router = Router()
    var lastRoute = "0"
    for i in 0..<1_000_00 {
      let routeString = "/\(i)"
      let route = Route(stringLiteral: routeString)
      router.use(route, .GET) { (_, _) in
        print("Handled: \(i)")
        return false
      }
      lastRoute = routeString
    }

    _ = router.handle(Request.makeSample(.GET, lastRoute), Response.makeForUnitTests())

    // App shouldn't crash
  }
}
