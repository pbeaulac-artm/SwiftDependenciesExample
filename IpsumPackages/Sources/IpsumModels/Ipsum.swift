public enum IpsumStyle: String, CaseIterable, Identifiable, Sendable {
    case lorem
    case beer
    case coffee
    case space
    case pirate

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .lorem: "Lorem Ipsum"
        case .beer: "Beer Ipsum"
        case .coffee: "Coffee Ipsum"
        case .space: "Space Ipsum"
        case .pirate: "Pirate Ipsum"
        }
    }
}

public struct IpsumEntry: Identifiable, Equatable, Sendable {
    public let id: String
    public let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
