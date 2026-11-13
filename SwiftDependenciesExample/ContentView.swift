//
//  ContentView.swift
//  SwiftDependenciesExample
//
//  Created by Pascale Beaulac on 2026-11-12.
//

import BeerFeature
import CoffeeFeature
import Dependencies
import IpsumDependencies
import IpsumModels
import LoremFeature
import PirateFeature
import SpaceFeature
import IpsumUseCases
import SwiftUI

struct ContentView: View {
    @State private var path: [IpsumDeepLink] = []
    @State private var deepLinkTask: Task<Void, Never>?
    @State private var deepLinkError: String?
    @Dependency(\.loadIpsumUseCase) private var loadIpsumUseCase

    var body: some View {
        NavigationStack(path: $path) {
            List(IpsumStyle.allCases) { style in
                NavigationLink(style.title, value: IpsumDeepLink(style: style))
            }
            .navigationTitle("Swift Dependencies Ipsum")
            .navigationDestination(for: IpsumDeepLink.self) { link in
                switch link.style {
                case .lorem: LoremView(targetEntryID: link.entryID)
                case .beer: BeerView(targetEntryID: link.entryID)
                case .coffee: CoffeeView(targetEntryID: link.entryID)
                case .space: SpaceView(targetEntryID: link.entryID)
                case .pirate: PirateView(targetEntryID: link.entryID)
                }
            }
        }
        .onOpenURL { url in
            deepLinkTask?.cancel()
            deepLinkTask = Task { await openDeepLink(url) }
        }
        .alert("Unable to open link", isPresented: Binding(
            get: { deepLinkError != nil },
            set: { if !$0 { deepLinkError = nil } }
        )) {
            Button("OK") { deepLinkError = nil }
        } message: {
            Text(deepLinkError ?? "")
        }
    }

    private func openDeepLink(_ url: URL) async {
        do {
            let link = try IpsumDeepLink(url: url, scheme: "swiftdependenciesexample")
            if link.entryID != nil {
                let entries = try await loadIpsumUseCase.load(link.style)
                try link.validateEntry(in: entries)
            }
            try Task.checkCancellation()
            deepLinkError = nil
            path = [link]
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            deepLinkError = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
