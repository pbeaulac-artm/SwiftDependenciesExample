import Dependencies
import Foundation
import IpsumDependencies
import IpsumModels
import Observation

@Observable @MainActor
final class PirateViewModel {
    private(set) var entries: [IpsumEntry] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    @ObservationIgnored @Dependency(\.loadIpsumUseCase)
    private var loadIpsumUseCase

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let entries = try await loadIpsumUseCase.load(.pirate)
            try Task.checkCancellation()
            self.entries = entries
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
