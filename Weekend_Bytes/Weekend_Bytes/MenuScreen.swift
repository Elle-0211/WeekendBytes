//
//  MenuScreen.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//

import SwiftUI

// MARK: - Menu Screen
// This view displays the different menu categories and their items, matching the provided image.
struct MenuScreen: View {
    @EnvironmentObject var appManager: AppManager
    @State private var selectedCategory = "Hotdogs"
    private let categories = ["Hotdogs", "Fries", "Burger", "Limited", "Drinks"]
    
    var body: some View {
        VStack {
            // Categories tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category)
                                .font(.custom("Baloo2-Bold", size: 16))
                                .foregroundColor(selectedCategory == category ? Color(hex: "E9351D") : .black)
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedCategory == category ? Color(hex: "E9351D") : .clear),
                            alignment: .bottom
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            
            // Menu Items Grid
            ScrollView {
                VStack(spacing: 20) {
                    if let items = menuItems[selectedCategory] {
                        ForEach(items, id: \.id) { item in
                            MenuItemRow(item: item)
                        }
                    } else {
                        Text("No items available for this category.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding(.top)
            }
        }
    }
}

// A helper view for a menu item row, including the "Add to Cart" button.
struct MenuItemRow: View {
    @EnvironmentObject var appManager: AppManager
    let item: Item
    
    var body: some View {
        HStack {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.custom("Baloo2-Bold", size: 16))
                Text(item.description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    // Fixed: Price formatting
                    Text("₱ \(item.price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", item.price) : String(format: "%.2f", item.price))")
                        .font(.custom("Baloo2-Bold", size: 14))
                        .foregroundColor(Color(hex: "E9351D"))
                    
                    Spacer()
                    
                    Button(action: {
                        appManager.addToCart(item: item)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "E9351D"))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
