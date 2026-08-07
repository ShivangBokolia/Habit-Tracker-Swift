// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HabitTrackerCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "HabitTrackerCore", targets: ["HabitTrackerCore"])
    ],
    targets: [
        .target(name: "HabitTrackerCore"),
        .testTarget(name: "HabitTrackerCoreTests", dependencies: ["HabitTrackerCore"])
    ]
)