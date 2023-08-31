// swift-tools-version: 5.8

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "TextFormationSTTextViewPlugin",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "TextFormationSTTextViewPlugin", targets: ["TextFormationSTTextViewPlugin"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/krzyzanowskim/STTextView", from: "0.8.10"),
        .package(path: "/Users/matt/Developer/STTextView"),
//        .package(url: "https://github.com/ChimeHQ/TextFormation", from: "0.8.0"),
		.package(path: "/Users/matt/Chime/Code/TextFormation"),
		.package(url: "https://github.com/ChimeHQ/TextStory", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TextFormationSTTextViewPlugin",
            dependencies: [
                .product(name: "STTextView", package: "STTextView"),
				"TextStory",
                "TextFormation",
            ],
            swiftSettings: settings),
        .testTarget(
            name: "TextFormationSTTextViewPluginTests",
            dependencies: ["TextFormationSTTextViewPlugin"],
            swiftSettings: settings),
    ]
)
