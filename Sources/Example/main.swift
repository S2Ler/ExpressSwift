import ExpressSwift
import Foundation
import NIOHTTP1

let express = Express(config: .default)
express.all { _, _ in
  print("Method called")
  return true
}

express.method(.POST) { request, response in
  guard let body = request.body,
    let bodyStr = String(data: body, encoding: .utf8) else {
    response.status = .badRequest
    response.send("Error")
    return false
  }
  print("Body: \(bodyStr)")
  response.send("Body: \(bodyStr)")
  return false
}

express.listen(8888)
