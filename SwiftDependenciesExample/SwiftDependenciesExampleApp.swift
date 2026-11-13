//
//  SwiftDependenciesExampleApp.swift
//  SwiftDependenciesExample
//
//  Created by Pascale Beaulac on 2026-11-12.
//

import Dependencies
import IpsumDatabase
import IpsumDependencies
import IpsumRepositoryLive
import SwiftUI

@main
struct SwiftDependenciesExampleApp: App {
    init() {
        prepareDependencies {
            $0.ipsumRepository = IpsumRepositoryLive(database: IpsumDatabase())
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
