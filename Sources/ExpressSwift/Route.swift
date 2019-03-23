import Foundation

public struct Route: ExpressibleByStringLiteral {
  private var components: [Component]

  public static let asteriks: Route = "*"

  public init(stringLiteral rawRoute: String) {
    components = Route.components(from: rawRoute)
  }

  internal func matches(_ path: Path, parameters: inout [String: String], partially: Bool = false) -> Bool {
    guard path.count == components.count || (partially && (path.count > components.count)) else {
      return false
    }

    for idx in 0 ..< components.count {
      let component = components[idx]
      let pathComponent = path[idx]

      if !component.matches(pathComponent, parameters: &parameters) {
        return false
      }
    }

    return true
  }

  /// Returns removed components
  internal func removeLeading(from path: inout Path) -> [String] {
    var removedComponents: [String] = []

    for component in components {
      guard !path.isEmpty else { break }
      var parameters: [String: String] = [:]
      if component.matches(path[0], parameters: &parameters) {
        let removedComponent = path.removeFirstComponent()
        removedComponents.append(removedComponent)
      }
      else {
        break
      }
    }

    return removedComponents
  }
}

private extension Route {
  enum Component {
    case constant(String)
    case willcard
    case parameter(name: String)

    func matches(_ pathComponent: String, parameters: inout [String: String]) -> Bool {
      switch self {
      case .constant(let constant):
        return constant == pathComponent
      case .willcard:
        return true
      case .parameter(let name):
        parameters[name] = pathComponent
        return true
      }
    }
  }

  static func components(from _rawRoute: String) -> [Component] {
    let rawRoute: Substring
    if _rawRoute.hasPrefix(Path.componentSeparator) {
      rawRoute = _rawRoute.dropFirst()
    }
    else {
      rawRoute = _rawRoute[_rawRoute.startIndex ..< _rawRoute.endIndex]
    }

    return rawRoute
      .exps_components(separatedBy: Path.componentSeparatorChar)
      .compactMap { (rawComponent: String) -> Component? in
        if rawComponent == "*" {
          return .willcard
        }
        else if rawComponent.hasPrefix(":") {
          let parameterName = rawComponent.dropFirst()
          return .parameter(name: String(parameterName))
        }
        else if rawComponent == "" {
          return nil
        }
        else {
          return .constant(rawComponent)
        }
      }
  }
}
