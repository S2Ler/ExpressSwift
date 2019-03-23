import Foundation

internal extension StringProtocol {
  func exps_components(separatedBy separator: Character) -> [String] {
    var components: [String] = []
    var currentComponent: String = ""
    for c in self {
      if c == separator {
        components.append(currentComponent)
        currentComponent = ""
      }
      else {
        currentComponent.append(c)
      }
    }

    if !currentComponent.isEmpty {
      components.append(currentComponent)
    }

    return components
  }
}
