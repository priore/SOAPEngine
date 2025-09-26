// swift-tools-version:5.5
import PackageDescription


let package = Package(
    name: "SOAPEngine",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "SOAPEngine",
            targets: ["SOAPEngine"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SOAPEngine",
            dependencies: [
                .target(name: "libxml2", condition: .when(platforms: [.iOS, .tvOS]))
            ], 
            path: "SOAPEngine",
            publicHeadersPath: "Headers",
            linkerSettings: [
                .linkedFramework("Security"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("Accounts", .when(platforms: [.iOS, .macOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS]))
            ]
        ),
        .systemLibrary(
            name: "libxml2",
            path: "Modules"
        )
    ]
)
