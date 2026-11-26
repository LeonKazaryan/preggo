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
        // Without GoogleService-Info.plist the app still runs: Firestore sync is skipped
        // and the Gemini key is read from Secrets.plist instead of Remote Config.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("⚠️ GoogleService-Info.plist not found — running without Firebase.")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(documentStore)
        }
    }
}
