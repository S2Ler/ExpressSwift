workflow "ExpressSwift Linux Build" {
  on = "push"
  resolves = ["Swift Package Test"]
}

action "Swift Package Build" {
  uses = "diejmon/ExpressSwift@master"
  runs = "swift build --configuration release"
}

action "Swift Package Test" {
  uses = "diejmon/ExpressSwift@master"
  runs = "swift test --configuration release"
  needs = ["Swift Package Build"]
}
