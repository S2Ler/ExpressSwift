import Foundation

private func certificatesDir() -> URL {
  URL(fileURLWithPath: #file).deletingLastPathComponent()
}

internal func certificatesPath() -> String {
  certificatesDir().appendingPathComponent("ExpressSwiftCertificates.pem").path
}

internal func privateKeyPath() -> String {
  certificatesDir().appendingPathComponent("ExpressSwift.pem").path
}
