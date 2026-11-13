import IpsumModels
import SwiftUI

public struct IpsumListContent: View {
    private let entries: [IpsumEntry]
    private let isLoading: Bool
    private let errorMessage: String?
    private let targetEntryID: String?
    private let retry: () async -> Void

    public init(entries: [IpsumEntry], isLoading: Bool, errorMessage: String?, targetEntryID: String? = nil, retry: @escaping () async -> Void) {
        self.entries = entries
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.targetEntryID = targetEntryID
        self.retry = retry
    }

    public var body: some View {
        if isLoading {
            ProgressView("Loading...")
        } else if let errorMessage {
            ContentUnavailableView {
                Label("Unable to load", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task { await retry() }
                }
            }
        } else {
            ScrollViewReader { proxy in
                List(entries) { entry in
                    Text(entry.text)
                        .padding(.vertical, 8)
                        .id(entry.id)
                        .listRowBackground(entry.id == targetEntryID ? Color.accentColor.opacity(0.15) : Color.clear)
                        .accessibilityAddTraits(entry.id == targetEntryID ? [.isSelected] : [])
                }
                .onAppear {
                    if let targetEntryID {
                        proxy.scrollTo(targetEntryID, anchor: .center)
                    }
                }
                .onChange(of: targetEntryID) { _, entryID in
                    if let entryID {
                        proxy.scrollTo(entryID, anchor: .center)
                    }
                }
                .overlay {
                    if entries.isEmpty {
                        ContentUnavailableView("No entries", systemImage: "text.alignleft")
                    }
                }
            }
        }
    }
}
