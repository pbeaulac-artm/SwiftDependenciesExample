import Dependencies
import DependenciesTestSupport
import Foundation
import IpsumDatabase
import IpsumDependencies
import IpsumModels
import IpsumRepositoryLive
import IpsumUseCases
import Testing
@testable import BeerFeature
@testable import CoffeeFeature
@testable import LoremFeature
@testable import PirateFeature
@testable import SpaceFeature

@Suite(.dependencies) @MainActor
struct IpsumTests {
    @Test func allFeaturesResolveTheUseCaseFromTheRepository() async {
        let database = IpsumDatabase()
        await withDependencies {
            $0.context = .live
            $0.ipsumRepository = IpsumRepositoryLive(database: database)
        } operation: {
            let lorem = LoremViewModel()
            let beer = BeerViewModel()
            let coffee = CoffeeViewModel()
            let space = SpaceViewModel()
            let pirate = PirateViewModel()

            await lorem.load()
            await beer.load()
            await coffee.load()
            await space.load()
            await pirate.load()

            #expect(lorem.entries == (await database.entries(for: .lorem)))
            #expect(beer.entries == (await database.entries(for: .beer)))
            #expect(coffee.entries == (await database.entries(for: .coffee)))
            #expect(space.entries == (await database.entries(for: .space)))
            #expect(pirate.entries == (await database.entries(for: .pirate)))
            #expect(!lorem.entries.isEmpty)
            #expect(lorem.errorMessage == nil)
            #expect(beer.errorMessage == nil)
            #expect(coffee.errorMessage == nil)
            #expect(space.errorMessage == nil)
            #expect(pirate.errorMessage == nil)
        }
    }

    @Test func modelRetainsItsOverrideOutsideTheCreationScope() async {
        let viewModel = withDependencies {
            $0.loadIpsumUseCase = PreviewIpsumUseCase()
        } operation: {
            LoremViewModel()
        }

        await viewModel.load()

        #expect(viewModel.entries.first?.text == "Lorem Ipsum: a short preview paragraph.")
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @Test func nestedOverrideIsTemporaryForAnExistingModel() async {
        let viewModel = withDependencies {
            $0.loadIpsumUseCase = PreviewIpsumUseCase()
        } operation: {
            LoremViewModel()
        }

        await withDependencies {
            $0.loadIpsumUseCase = FixedUseCase()
        } operation: {
            await viewModel.load()
            #expect(viewModel.entries == [IpsumEntry(id: "fixed", text: "Temporary override.")])
        }

        await viewModel.load()
        #expect(viewModel.entries.first?.text == "Lorem Ipsum: a short preview paragraph.")
    }

    @Test(.dependency(\.context, .preview))
    func previewUsesSampleDataWithoutADatabase() async {
        let viewModel = BeerViewModel()

        await viewModel.load()

        #expect(viewModel.entries.first?.text == "Beer Ipsum: a short preview paragraph.")
        #expect(viewModel.errorMessage == nil)
    }

    @Test(.dependency(\.context, .live))
    func missingRepositoryConfigurationIsVisible() async {
        let viewModel = LoremViewModel()

        await viewModel.load()

        #expect(viewModel.entries.isEmpty)
        #expect(viewModel.errorMessage == "Prepare ipsumRepository before creating a feature view model.")
        #expect(!viewModel.isLoading)
    }

    @Test func loadFailureIsVisibleAndRetryClearsIt() async {
        let viewModel = withDependencies {
            $0.loadIpsumUseCase = FailingOnceUseCase()
        } operation: {
            LoremViewModel()
        }

        await viewModel.load()
        #expect(viewModel.errorMessage == "The database is unavailable.")
        #expect(viewModel.entries.isEmpty)
        #expect(!viewModel.isLoading)

        await viewModel.load()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.entries == [IpsumEntry(id: "retry", text: "Loaded after retry.")])
        #expect(!viewModel.isLoading)
    }

    @Test(.dependency(\.loadIpsumUseCase, CancellingUseCase()))
    func cancellationDoesNotPublishEntriesOrAnError() async {
        let viewModel = LoremViewModel()
        let task = Task { await viewModel.load() }
        await task.value

        #expect(viewModel.entries.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }
}

private struct FixedUseCase: LoadIpsumUseCaseProtocol {
    func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        [IpsumEntry(id: "fixed", text: "Temporary override.")]
    }
}

private enum TestError: LocalizedError {
    case unavailable

    var errorDescription: String? { "The database is unavailable." }
}

private actor FailingOnceUseCase: LoadIpsumUseCaseProtocol {
    private var shouldFail = true

    func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        if shouldFail {
            shouldFail = false
            throw TestError.unavailable
        }
        return [IpsumEntry(id: "retry", text: "Loaded after retry.")]
    }
}

private struct CancellingUseCase: LoadIpsumUseCaseProtocol {
    func load(_ style: IpsumStyle) async throws -> [IpsumEntry] {
        withUnsafeCurrentTask { $0?.cancel() }
        return [IpsumEntry(id: "cancelled", text: "This result must not be published.")]
    }
}
