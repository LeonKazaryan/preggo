//
//  MainTabView.swift
//  Preggo
//
//  Root tab container with 4 tabs: Home, Health, Documents, Profile.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: Tab = .home

    enum Tab: Int, CaseIterable {
        case home, health, documents, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                }
                .tag(Tab.home)

            HealthView()
                .tabItem {
                    Label("Health", systemImage: selectedTab == .health ? "heart.text.square.fill" : "heart.text.square")
                }
                .tag(Tab.health)

            DocumentsView()
                .tabItem {
                    Label("Documents", systemImage: selectedTab == .documents ? "doc.text.fill" : "doc.text")
                }
                .tag(Tab.documents)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == .profile ? "person.circle.fill" : "person.circle")
                }
                .tag(Tab.profile)
        }
        .tint(Color.preggoRose)
    }
}
