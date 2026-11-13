import IpsumUI
import SwiftUI

public struct LoremView: View {
    @State private var viewModel = LoremViewModel()

    private let targetEntryID: String?

    public init(targetEntryID: String? = nil) {
        self.targetEntryID = targetEntryID
    }

    public var body: some View {
        IpsumListContent(
            entries: viewModel.entries,
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            targetEntryID: targetEntryID,
            retry: { await viewModel.load() }
        )
        .navigationTitle("Lorem Ipsum")
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack { LoremView() }
}
