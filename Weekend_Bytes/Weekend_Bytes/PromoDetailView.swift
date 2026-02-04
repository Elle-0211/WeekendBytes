//
//  PromoDetailView.swift
//  Weekend_Bytes
//
//  Created by STUDENT on 10/23/25.
//

import SwiftUI

struct PromoDetailView: View {
    let promo: Promo
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmAlert = false
    @State private var showSuccessAlert = false
    @State private var navigateToMenu = false

    // MARK: - Theme Color
    var themeColor: Color {
        switch promo.name {
        case "TGIF! Thank God It's Friday":
            return Color(hex: "E9351D")
        case "Saturday Saver":
            return Color(hex: "F9EB05")
        case "Sunday Feast":
            return Color(hex: "FFA525")
        default:
            return Color.red
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Header Image
                ZStack(alignment: .topLeading) {
                    Image(promo.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()

                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(themeColor)
                            .font(.system(size: 22, weight: .bold))
                            .padding()
                    }
                }

                // MARK: - Promo Info
                VStack(alignment: .leading, spacing: 16) {
                    Text(promo.name)
                        .font(.custom("Baloo2-Bold", size: 24))
                        .foregroundColor(.black)

                    Text(promo.description)
                        .font(.custom("Baloo2-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.bottom, 8)

                    Divider()

                    Text("Terms and Conditions")
                        .font(.custom("Baloo2-Bold", size: 16))
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Valid for minimum order of ₱190")
                        Text("• Applicable for Delivery and Pick-up")
                        Text("• Valid payment with COD or GCash")
                        Text("• Limited to 1 redemption per week")
                    }
                    .font(.custom("Baloo2-Regular", size: 14))
                    .foregroundColor(.black)
                }
                .padding()

                Spacer()

                // MARK: - Use Now Button
                Button(action: {
                    showConfirmAlert = true
                }) {
                    Text("Use Now")
                        .font(.custom("Baloo2-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            // Confirmation Alert
            .alert("Use this promo?", isPresented: $showConfirmAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Apply") {
                    applyPromo(promo)
                }
            } message: {
                Text("Would you like to apply the '\(promo.name)' promo to your order?")
            }

            // Success Alert
            .alert("Promo Applied!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    navigateToMenu = true
                }
            } message: {
                Text("\(promo.name) has been successfully applied.")
            }

            .navigationDestination(isPresented: $navigateToMenu) {
                DashboardView()
            }

            .navigationBarHidden(true)
        }
    }

    // MARK: - Apply Promo Function
    func applyPromo(_ promo: Promo) {
        UserDefaults.standard.set(promo.name, forKey: "activePromo")
        showSuccessAlert = true
    }
}
