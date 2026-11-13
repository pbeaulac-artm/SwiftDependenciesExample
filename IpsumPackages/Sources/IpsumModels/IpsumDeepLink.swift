import Foundation

public struct IpsumDeepLink: Hashable, Sendable {
    public let style: IpsumStyle
    public let entryID: String?

    public init(style: IpsumStyle, entryID: String? = nil) {
        self.style = style
        self.entryID = entryID
    }

    public init(url: URL, scheme: String) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == scheme,
              components.host == "ipsum",
              components.user == nil, components.password == nil, components.port == nil,
              components.query == nil, components.fragment == nil else {
            throw Failure.invalidURL
        }
        let parts = components.path.split(separator: "/", omittingEmptySubsequences: false)
        guard (parts.count == 2 || parts.count == 3),
              parts[0].isEmpty,
              let style = IpsumStyle(rawValue: String(parts[1])),
              parts.count != 3 || !parts[2].isEmpty else {
            throw Failure.invalidURL
        }
        self.style = style
        entryID = parts.count == 3 ? String(parts[2]) : nil
    }

    public func validateEntry(in entries: [IpsumEntry]) throws {
        if let entryID, !entries.contains(where: { $0.id == entryID }) {
            throw Failure.missingParagraph
        }
    }

    public enum Failure: LocalizedError {
        case invalidURL
        case missingParagraph

        public var errorDescription: String? {
            switch self {
            case .invalidURL: "This ipsum link is invalid."
            case .missingParagraph: "The linked paragraph does not exist."
            }
        }
    }
}
