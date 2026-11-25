//
//  PreggoApp.swift
//  Preggo
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct PreggoApp: App {

    @State private var appState = AppState()
    @State private var documentStore = DocumentStore()

    init() {
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(documentStore)
        }
    }
}
