//
//  PreggoApp.swift
//  Preggo
//

import SwiftUI

@main
struct PreggoApp: App {

    @State private var appState = AppState()
    @State private var documentStore = DocumentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(documentStore)
        }
    }
}
