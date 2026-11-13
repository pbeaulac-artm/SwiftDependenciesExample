import IpsumUI
import SwiftUI

public struct CoffeeView: View {
    @State private var viewModel = CoffeeViewModel()

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
        .navigationTitle("Coffee Ipsum")
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack { CoffeeView() }
}
