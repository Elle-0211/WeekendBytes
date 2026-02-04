//
//  HomeView.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//

import SwiftUI

// MARK: - Home Screen
struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - New Items Section
                    VStack(alignment: .leading) {
                        Text("New items")
                            .font(.custom("Baloo2-Bold", size: 24))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(newItems, id: \.id) { item in
                                    NavigationLink(destination: MenuScreen()) {
                                        NewItemRow(item: item)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Promos Section
                    VStack(alignment: .leading) {
                        Text("Promos")
                            .font(.custom("Baloo2-Bold", size: 24))
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            ForEach(promos, id: \.id) { promo in
                                NavigationLink(destination: PromoDetailView(promo: promo)) {
                                    PromoCard(promo: promo)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .background(Color(hex: "F2F2F7"))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - New Item Row
struct NewItemRow: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 100)
                .clipped()
                .cornerRadius(10)
            
            Text(item.name)
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.black)
            
            Text("₱\(item.price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", item.price) : String(format: "%.2f", item.price))")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color(hex: "E9351D"))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Promo Card
struct PromoCard: View {
    let promo: Promo
    
    var body: some View {
        HStack(spacing: 15) {
            Image(promo.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 80)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(promo.name)
                    .font(.custom("Baloo2-Bold", size: 16))
                    .foregroundColor(.black)
                Text(promo.description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
