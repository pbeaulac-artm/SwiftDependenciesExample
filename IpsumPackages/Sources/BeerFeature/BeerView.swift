import IpsumUI
import SwiftUI

public struct BeerView: View {
    @State private var viewModel = BeerViewModel()

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
        .navigationTitle("Beer Ipsum")
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack { BeerView() }
}
