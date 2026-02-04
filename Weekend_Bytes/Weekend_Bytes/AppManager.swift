//
//  AppManager.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppManager: ObservableObject {
    @Published var cartItems: [Item: Int] = [:]
    @Published var total: Double = 0.0
    @Published var subtotal: Double = 0.0
    @Published var isLoggedIn: Bool = false
    @Published var isCheckingAuth: Bool = true
    let deliveryFee: Double = 25.0
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = (user != nil)
        }
    }
    
    // MARK: - Cart Management
    func addToCart(item: Item) {
        cartItems[item, default: 0] += 1
        updateTotals()
    }
    
    func removeItem(item: Item) {
        if let currentCount = cartItems[item] {
            if currentCount > 1 {
                cartItems[item] = currentCount - 1
            } else {
                cartItems.removeValue(forKey: item)
            }
        }
        updateTotals()
    }
    
    func removeCompletely(item: Item) {
        cartItems.removeValue(forKey: item)
        updateTotals()
    }
    
    func updateTotals() {
        subtotal = cartItems.reduce(0) { $0 + (Double($1.key.price) * Double($1.value)) }
        var totalPrice = subtotal + deliveryFee
        
        if let activePromo = UserDefaults.standard.string(forKey: "activePromo") {
            switch activePromo {
            case "TGIF!": totalPrice *= 0.8
            case "Saturday Saver": handleSaturdaySaver()
            case "Sunday Feast": totalPrice *= 0.5
            default: break
            }
        }
        total = totalPrice
    }
    
    private func handleSaturdaySaver() {
        let fries = Item(
            name: "Cheesy Fries",
            description: "Free fries with Saturday Saver promo!",
            price: 0.0,
            image: "cheeseFries"
        )
        let qualifyingCount = cartItems.filter {
            $0.key.name.localizedCaseInsensitiveContains("burger") ||
            $0.key.name.localizedStandardContains("byte")
        }.reduce(0) { $0 + $1.value }
        
        if qualifyingCount >= 2 {
            if cartItems[fries] == nil { cartItems[fries] = 1 }
        } else {
            cartItems.removeValue(forKey: fries)
        }
    }
    
    func clearPromo() {
        UserDefaults.standard.removeObject(forKey: "activePromo")
    }
    
    func clearCart() {
        cartItems = [:]
        total = 0.0
        subtotal = 0.0
    }
    
    // MARK: - Save Order to Firestore
    func saveOrder(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        
        let orderItems = cartItems.reduce(into: [String: Int]()) { result, entry in
            result[entry.key.name] = entry.value
        }
        
        let orderData: [String: Any] = [
            "date": formattedDate(),
            "items": orderItems,
            "total": total
        ]
        
        db.collection("users")
            .document(user.uid)
            .collection("orders")
            .addDocument(data: orderData) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
