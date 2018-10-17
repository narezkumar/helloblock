// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .exact("0.9.0")),

        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .exact("1.6.1"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor","SwiftyBeaver"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

