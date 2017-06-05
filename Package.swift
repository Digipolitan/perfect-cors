// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "PerfectCORS",
    dependencies: [
        .Package(url: "https://github.com/Digipolitan/perfect-middleware-swift.git", majorVersion: 1)
    ]
)
