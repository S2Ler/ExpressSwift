import XCTest

extension LayerTests {
  static let __allTests = [
    ("testLayerByMethod", testLayerByMethod),
    ("testLayerByPath", testLayerByPath),
  ]
}

extension RouterTests {
  static let __allTests = [
    ("testInnerRouter", testInnerRouter),
    ("testRouter", testRouter),
    ("testRouter2", testRouter2),
  ]
}

#if !os(macOS)
  public func __allTests() -> [XCTestCaseEntry] {
    return [
      testCase(LayerTests.__allTests),
      testCase(RouterTests.__allTests),
    ]
  }
#endif
