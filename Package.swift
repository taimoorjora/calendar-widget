// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CalendarWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CalendarWidget", targets: ["CalendarWidget"])
    ],
    targets: [
        .executableTarget(
            name: "CalendarWidget"
        ),
        .testTarget(
            name: "CalendarWidgetTests",
            dependencies: ["CalendarWidget"]
        )
    ]
)
