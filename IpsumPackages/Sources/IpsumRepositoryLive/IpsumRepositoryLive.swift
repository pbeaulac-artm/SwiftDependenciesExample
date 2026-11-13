import IpsumDatabase
import IpsumModels
import IpsumRepository

public final class IpsumRepositoryLive: IpsumRepositoryProtocol {
    private let database: IpsumDatabase

    public init(database: IpsumDatabase) {
        self.database = database
    }

    public func entries(for style: IpsumStyle) async throws -> [IpsumEntry] {
        await database.entries(for: style)
    }
}
