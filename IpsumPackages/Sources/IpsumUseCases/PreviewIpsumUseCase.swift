import IpsumModels

public struct PreviewIpsumUseCase: LoadIpsumUseCaseProtocol {
    public init() {}

    public func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        [
            IpsumEntry(id: "preview-1", text: "\(style.title): a short preview paragraph."),
            IpsumEntry(id: "preview-2", text: "\(style.title): another paragraph, without any database.")
        ]
    }
}
