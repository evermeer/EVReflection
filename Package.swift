// swift-tools-version:5.1
//
//  Package.swift
//  EVReflection
//
//  Created by Axel Cantor on 28/01/20.
//  Copyright © 2015 evict. All rights reserved.
//

import PackageDescription

let package = Package(name: "EVReflection",
                      platforms: [.macOS(.v10_11),
                                  .iOS(.v8),
                                  .tvOS(.v9),
                                  .watchOS(.v3)],
                      products: [.library(name: "EVReflection",
                                          targets: ["EVReflection"])],
                      targets: [.target(name: "EVReflection",
                                        path: "Source")],
                      swiftLanguageVersions: [.v5])
