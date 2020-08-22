# ExpressSwift

![ExpressSwift Linux Build](https://github.com/S2Ler/ExpressSwift/workflows/ExpressSwift%20Linux%20Build/badge.svg)

Swift 5.2, macOS, Linux, ARM64, Raspberry Pi

[ExpressJS](https://expressjs.com) inspired web server framework on top of [Swift NIO](https://github.com/apple/swift-nio).

## TODO:
- [ ] Error handling

## Installation

Use [SPM](https://swift.org/package-manager/).

Sample `Package.swift`
```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "ProjectName",
  products: [
    .executable(name: "ProjectName", targets: ["ProjectName"]),
  ],
  dependencies: [
    .package(url: "https://github.com/diejmon/ExpressSwift.git", .upToNextMinor(from: "0.0.1")),
  ],
  targets: [
    .target(
      name: "ProjectName",
      dependencies: [
        .product(name: "ExpressSwift", package: "ExpressSwift"),
      ]),
  ],
  swiftLanguageVersions: [.v5]
)
```

## Usage

```swift
import ExpressSwift
import Foundation

var cities: [String] = ["Belarus,Minsk"]
let citiesLock = NSLock()

let express = Express(config: .default)
express.all { _, _ in
  print("Will be called for every request")
  // Means that other route will be able to handle request.
  return true
}

// Will be called for all requests with uri: server/city and GET.
express.use("/city", .GET) { request, response in
  response.send("Minsk")
  return false
}

// :name is a parameter which can be accessed later from request.getParameter
express.use("/city/:name", .POST) { request, response in
  guard let cityName: String = request.getParameter("name") else { return true }
  print("Creating city with name: \(cityName)")
  citiesLock.lock(); defer { citiesLock.unlock() }
  cities.append(cityName)
  response.send("\(cities)")
  return false
}

struct Todo: Codable {
  let title: String
  let notes: String
}

var todos: [Todo] = [Todo(title: "Release ExpressSwift", notes: "git push")]
var todosLock = NSLock()

let todoRouter = Router()
todoRouter.all { (request, response) -> Bool in
  print("Todo router")
  return true
}

todoRouter.method(.GET) { (request, response) -> Bool in
  response.json(todos)
  return false
}

todoRouter.method(.POST) { (request, response) -> Bool in
  do {
    let todo = try request.json(Todo.self)
    todosLock.lock(); defer { todosLock.unlock() }
    todos.append(todo)
    response.status = .created
    response.send("")
  }
  catch {
    response.status = .badRequest
    response.send("Can't decode with error: \(error)")
  }

  return false
}

// When /todo route is found, the handling will proceed to todoRouter with /todo part substituted from route
express.use("/todo", todoRouter)

express.listen(8080)
```

## Setting up HTTPS server

Provide `NIOSSLContext` in `Express.Config`. See [HttpsExample](Sources/HttpsExample)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Please make sure to update tests as appropriate.
