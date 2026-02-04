//
//  CartView.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//

import SwiftUI

// MARK: - Cart View
struct CartView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var navigateToDelivery = false
    @State private var showEmptyCartAlert = false
    
    var activePromo: String? {
           UserDefaults.standard.string(forKey: "activePromo")
       }
    
    var body: some View {
        if navigateToDelivery {
            DeliveryView()
        } else {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(appManager.cartItems.keys), id: \.self) { item in
                            if let quantity = appManager.cartItems[item] {
                                CartItemRow(item: item, quantity: quantity)
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("₱ \(String(format: "%.2f", appManager.subtotal))")
                    }
                    HStack {
                        Text("Delivery Fee")
                        Spacer()
                        Text("₱ \(String(format: "%.2f", appManager.deliveryFee))")
                    }
                    
                    if let promo = activePromo {
                        HStack {
                            Text("Promo Applied")
                            .font(.custom("Baloo2-Bold", size: 16))
                            .foregroundColor(Color(hex: "E9351D"))
                            Spacer()
                            Text(promo)
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(Color(hex: "E9351D"))
                        }
                    }
                    Divider()
                        .background(Color.black)
                    HStack {
                        Text("Total")
                            .font(.custom("Baloo2-Bold", size: 22))
                        Spacer()
                        Text("₱ \(String(format: "%.2f", appManager.total))")
                            .font(.custom("Baloo2-Bold", size: 22))
                            .foregroundColor(Color(hex: "E9351D"))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding()
                
                Button(action: {
                    if appManager.cartItems.isEmpty {
                        showEmptyCartAlert = true
                    } else {
                        navigateToDelivery = true
                    }
                }) {
                    Text("Checkout")
                }
                .buttonStyle(MainButtonStyle())
                .padding(.horizontal)
                .alert(isPresented: $showEmptyCartAlert) {
                    Alert(title: Text("Cart is empty"),
                          message: Text("Please add atleast one item to your cart"),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

// A helper view for a single item in the cart.
struct CartItemRow: View {
    @EnvironmentObject var appManager: AppManager
    let item: Item
    let quantity: Int
    
    var body: some View {
        HStack {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.custom("Baloo2-Bold", size: 16))
                Text("₱ \(String(format: "%.2f", item.price))")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                
                // Plus and minus buttons
                HStack(spacing: 10) {
                    Button(action: {
                        appManager.removeItem(item: item)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "E9351D"))
                    }
                    
                    Text("\(quantity)")
                        .font(.custom("Baloo2-Bold", size: 14))
                    
                    Button(action: {
                        appManager.addToCart(item: item)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "E9351D"))
                    }
                }
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Delete button
            Button(action: {
                appManager.removeCompletely(item: item)
            }) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            .padding(.leading, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
