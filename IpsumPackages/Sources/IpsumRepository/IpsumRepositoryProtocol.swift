import IpsumModels

public protocol IpsumRepositoryProtocol: Sendable {
    func entries(for style: IpsumStyle) async throws -> [IpsumEntry]
}
