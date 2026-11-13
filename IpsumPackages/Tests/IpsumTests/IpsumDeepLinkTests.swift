import Foundation
import IpsumModels
import Testing

struct IpsumDeepLinkTests {
    @Test(arguments: IpsumStyle.allCases)
    func acceptsFeatureAndParagraphLinks(style: IpsumStyle) throws {
        let featureURL = try #require(URL(string: "example://ipsum/\(style.rawValue)"))
        let paragraphURL = try #require(URL(string: "example://ipsum/\(style.rawValue)/3"))

        #expect(try IpsumDeepLink(url: featureURL, scheme: "example") == IpsumDeepLink(style: style))
        #expect(try IpsumDeepLink(url: paragraphURL, scheme: "example") == IpsumDeepLink(style: style, entryID: "3"))
    }

    @Test(arguments: [
        "other://ipsum/beer", "example://other/beer", "example://ipsum/unknown",
        "example://ipsum/beer/", "example://ipsum/beer/0/extra", "example://ipsum/beer//0",
        "example://ipsum/beer?entry=0", "example://ipsum/beer#0",
        "example://user@ipsum/beer", "example://ipsum:123/beer", "example://ipsum/beer/0%2Fextra"
    ])
    func rejectsMalformedLinks(value: String) throws {
        let url = try #require(URL(string: value))
        #expect(throws: IpsumDeepLink.Failure.self) {
            try IpsumDeepLink(url: url, scheme: "example")
        }
    }

    @Test func verifiesTheParagraphAgainstLoadedEntries() throws {
        let entries = [IpsumEntry(id: "0", text: "An existing paragraph.")]
        try IpsumDeepLink(style: .beer, entryID: "0").validateEntry(in: entries)
        try IpsumDeepLink(style: .beer).validateEntry(in: [])

        #expect(throws: IpsumDeepLink.Failure.self) {
            try IpsumDeepLink(style: .beer, entryID: "99").validateEntry(in: entries)
        }
    }
}
