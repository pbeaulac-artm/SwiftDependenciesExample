import IpsumModels
import IpsumRepository

public protocol LoadIpsumUseCaseProtocol: Sendable {
    func load(_ style: IpsumStyle) async throws -> [IpsumEntry]
}

public struct LoadIpsumUseCase: LoadIpsumUseCaseProtocol {
    private let repository: any IpsumRepositoryProtocol

    public init(repository: any IpsumRepositoryProtocol) {
        self.repository = repository
    }

    public func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        try await repository.entries(for: style)
    }
}
