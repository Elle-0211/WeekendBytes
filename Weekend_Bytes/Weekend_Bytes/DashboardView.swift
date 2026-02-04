//
//  Dashboard.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//

import SwiftUI

// MARK: - Dashboard
// The main container view that holds the tab bar and switches between different content views.
struct DashboardView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var selectedTab: Tab = .home
    
    enum Tab: String {
        case home, menu, cart, profile
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Display the selected content view based on the current tab.
                switch selectedTab {
                case .home:
                    HomeView()
                case .menu:
                    MenuScreen()
                case .cart:
                    CartView()
                case .profile:
                    ProfileView()
                }
                
                Spacer()
                
                // MARK: - Bottom Navigation Bar
                // Custom tab bar for navigating the app.
                HStack {
                    Spacer()
                    TabBarButton(imageName: "house.fill", title: "Home", isSelected: selectedTab == .home) {
                        selectedTab = .home
                    }
                    Spacer()
                    TabBarButton(imageName: "fork.knife", title: "Menu", isSelected: selectedTab == .menu) {
                        selectedTab = .menu
                    }
                    Spacer()
                    TabBarButton(imageName: "cart.fill", title: "Cart", isSelected: selectedTab == .cart, cartItemCount: appManager.cartItems.count) {
                        selectedTab = .cart
                    }
                    Spacer()
                    TabBarButton(imageName: "person.fill", title: "Profile", isSelected: selectedTab == .profile) {
                        selectedTab = .profile
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .shadow(radius: 5)
            }
            .navigationTitle(selectedTab.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileSettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color(hex: "000000"))
                    }
                }
            }
        }
    }
}

extension DashboardView.Tab {
    var title: String {
        switch self {
        case .home:
            return "Weekend Menu"
        case .menu:
            return "Menu"
        case .cart:
            return "Your Cart"
        case .profile:
            return "Profile"
        }
    }
}

// Helper struct for a single tab bar button
struct TabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    var cartItemCount: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: 22))
                    .symbolVariant(.fill)
                    .foregroundColor(isSelected ? Color(hex: "E9351D") : .gray)
                    .overlay(alignment: .topTrailing) {
                        if cartItemCount > 0 && title == "Cart" {
                            Text("\(cartItemCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -5)
                        }
                    }
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: "E9351D") : .gray)
            }
        }
    }
}
