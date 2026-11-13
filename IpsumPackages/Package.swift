// swift-tools-version: 6.1
import PackageDescription

let features = ["LoremFeature", "BeerFeature", "CoffeeFeature", "SpaceFeature", "PirateFeature"]
let dependencies: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")

let package = Package(
    name: "IpsumPackages",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: (features + ["IpsumModels", "IpsumDependencies", "IpsumDatabase", "IpsumRepositoryLive"]).map {
        .library(name: $0, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "1.17.2")
    ],
    targets: [
        .target(name: "IpsumModels"),
        .target(name: "IpsumRepository", dependencies: ["IpsumModels"]),
        .target(name: "IpsumDatabase", dependencies: ["IpsumModels"]),
        .target(name: "IpsumRepositoryLive", dependencies: ["IpsumRepository", "IpsumDatabase"]),
        .target(name: "IpsumUseCases", dependencies: ["IpsumRepository"]),
        .target(name: "IpsumDependencies", dependencies: ["IpsumUseCases", "IpsumRepository", dependencies]),
        .target(name: "IpsumUI", dependencies: ["IpsumModels"])
    ] + features.map {
        .target(name: $0, dependencies: ["IpsumDependencies", "IpsumModels", "IpsumUseCases", "IpsumUI", dependencies])
    } + [
        .testTarget(
            name: "IpsumTests",
            dependencies: features.map { .byName(name: $0) } + [
                "IpsumDependencies", "IpsumModels", "IpsumUseCases", "IpsumRepository",
                "IpsumRepositoryLive", "IpsumDatabase", dependencies,
                .product(name: "DependenciesTestSupport", package: "swift-dependencies")
            ]
        )
    ]
)
