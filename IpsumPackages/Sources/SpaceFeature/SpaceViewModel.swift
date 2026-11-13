import Dependencies
import Foundation
import IpsumDependencies
import IpsumModels
import Observation

@Observable @MainActor
final class SpaceViewModel {
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
            let entries = try await loadIpsumUseCase.load(.space)
            try Task.checkCancellation()
            self.entries = entries
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
