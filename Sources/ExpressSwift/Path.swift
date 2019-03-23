import Foundation

public struct Path: Equatable {
  private var componentsInReverseOrder: [String]

  internal static let componentSeparator = "/"
  internal static let componentSeparatorChar = Character(componentSeparator)

  internal var isEmpty: Bool {
    return componentsInReverseOrder.isEmpty
  }

  internal var count: Int {
    return componentsInReverseOrder.count
  }

  private static func components(from rawPath: String) -> [String] {
    let components = rawPath.exps_components(separatedBy: Path.componentSeparatorChar)
    if components.first == "" {
      return components.dropFirst().reversed()
    }
    else {
      return components.reversed()
    }
  }

  public init(_ rawPath: String) {
    componentsInReverseOrder = Path.components(from: rawPath)
  }

  private init(_ components: [String]) {
    componentsInReverseOrder = components.reversed()
  }

  /// Returns removed path
  internal mutating func removeLeadingRoute(_ route: Route) -> Path {
    let removedComponents = route.removeLeading(from: &self)
    return Path(removedComponents)
  }

  internal mutating func restoreLeadingComponent(_ pathComponent: Path) {
    componentsInReverseOrder.append(contentsOf: pathComponent.componentsInReverseOrder)
  }

  internal func hasPrefix(_ prefix: Path) -> Bool {
    if prefix.componentsInReverseOrder.count > componentsInReverseOrder.count {
      return false
    }

    var prefixIdx = prefix.componentsInReverseOrder.count - 1
    var componentsIdx = componentsInReverseOrder.count - 1

    while prefixIdx >= 0 {
      if prefix.componentsInReverseOrder[prefixIdx] != componentsInReverseOrder[componentsIdx] {
        return false
      }

      prefixIdx -= 1
      componentsIdx -= 1
    }

    return true
  }

  internal subscript(idx: Int) -> String {
    return componentsInReverseOrder[componentsInReverseOrder.endIndex - idx - 1]
  }

  internal mutating func removeFirstComponent() -> String {
    return componentsInReverseOrder.removeLast()
  }
}

extension Path: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    componentsInReverseOrder = Path.components(from: value)
  }
}

extension Path: CustomDebugStringConvertible {
  public var debugDescription: String {
    var components: [String] = componentsInReverseOrder.reversed()
    components.insert("", at: 0)
    return components.joined(separator: Path.componentSeparator)
  }
}
