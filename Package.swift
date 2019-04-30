// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SOAPEngine",
    platforms: [
        .iOS(.v8)
    ],
    pkgConfig: "libxml2",
    products: [
        .library(name: "SOAPEngine", type: .static, targets: ["SOAPEngine"]),
    ],
    targets: [
        .target(
        	name: "SOAPEngine", 
        	dependencies: [], 
        	path: "./SOAPEngine64.framework",
        	exclude: [
        		"Modules",
        		"Info.plist"
        	]
        ),
    ]
)