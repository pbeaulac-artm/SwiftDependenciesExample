import Dependencies
import Foundation
import IpsumModels
import IpsumRepository
import IpsumUseCases

public extension DependencyValues {
    var ipsumRepository: any IpsumRepositoryProtocol {
        get { self[IpsumRepositoryKey.self] }
        set { self[IpsumRepositoryKey.self] = newValue }
    }

    var loadIpsumUseCase: any LoadIpsumUseCaseProtocol {
        get { self[LoadIpsumUseCaseKey.self] }
        set { self[LoadIpsumUseCaseKey.self] = newValue }
    }
}

private enum IpsumRepositoryKey: DependencyKey {
    static let liveValue: any IpsumRepositoryProtocol = UnconfiguredIpsumRepository()
    static let testValue: any IpsumRepositoryProtocol = UnimplementedIpsumRepository()
}

private enum LoadIpsumUseCaseKey: DependencyKey {
    static var liveValue: any LoadIpsumUseCaseProtocol {
        @Dependency(\.ipsumRepository) var repository
        return LoadIpsumUseCase(repository: repository)
    }

    static let previewValue: any LoadIpsumUseCaseProtocol = PreviewIpsumUseCase()
    static let testValue: any LoadIpsumUseCaseProtocol = UnimplementedLoadIpsumUseCase()
}

private enum DependencyConfigurationError: LocalizedError {
    case repositoryNotPrepared
    case testDependencyNotOverridden

    var errorDescription: String? {
        switch self {
        case .repositoryNotPrepared:
            "Prepare ipsumRepository before creating a feature view model."
        case .testDependencyNotOverridden:
            "Override this dependency with withDependencies before using it in a test."
        }
    }
}

private struct UnconfiguredIpsumRepository: IpsumRepositoryProtocol {
    func entries(for style: IpsumStyle) async throws -> [IpsumEntry] {
        throw DependencyConfigurationError.repositoryNotPrepared
    }
}

private struct UnimplementedIpsumRepository: IpsumRepositoryProtocol {
    func entries(for style: IpsumStyle) async throws -> [IpsumEntry] {
        reportIssue("IpsumRepositoryProtocol.entries is unimplemented in this test.")
        throw DependencyConfigurationError.testDependencyNotOverridden
    }
}

private struct UnimplementedLoadIpsumUseCase: LoadIpsumUseCaseProtocol {
    func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        reportIssue("LoadIpsumUseCaseProtocol.load is unimplemented in this test.")
        throw DependencyConfigurationError.testDependencyNotOverridden
    }
}
