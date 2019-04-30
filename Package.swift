// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SOAPEngine",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "SOAPEngine", type: .static, targets: ["SOAPEngine"]),
    ],
    targets: [
		.systemLibrary(
    	    name: "libxml",
        	path: "Modules",
        	pkgConfig: "libxml-2.0",
        	providers: [
            	.brew(["libxml2"]),
            	.apt(["libxml2-dev"])
        	]),
        .target(
        	name: "SOAPEngine", 
        	dependencies: ["libxml"], 
        	path: "./SOAPEngine64.framework",
        	exclude: [
        		"Modules",
        		"Info.plist"
        	]),
    ]
)