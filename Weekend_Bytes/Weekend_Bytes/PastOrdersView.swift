import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Past Orders View
struct PastOrdersView: View {
    @State private var orders: [Order] = []
    @EnvironmentObject var appManager: AppManager
    @State private var navigateToCart = false

    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Past Orders")
                .font(.custom("Baloo2-Bold", size: 22))
                .padding(.bottom, 10)

            if orders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cart")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No past orders yet")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(orders) { order in
                            OrderRow(
                                order: order,
                                appManager: appManager,
                                navigateToCart: $navigateToCart
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Past Orders")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToCart) {
            CartView().environmentObject(appManager)
        }
        .onAppear {
            loadOrders()
        }
    }

    // MARK: - Load Firestore Orders
    private func loadOrders() {
        guard let user = Auth.auth().currentUser else { return }

        db.collection("users")
            .document(user.uid)
            .collection("orders")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading orders: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot {
                    self.orders = snapshot.documents.map { doc in
                        let data = doc.data()
                        return Order(
                            id: doc.documentID,
                            date: data["date"] as? String ?? "",
                            items: data["items"] as? [String: Int] ?? [:],
                            total: data["total"] as? Double ?? 0.0
                        )
                    }
                }
            }
    }
}

// MARK: - Order Row
struct OrderRow: View {
    let order: Order
    @ObservedObject var appManager: AppManager
    @Binding var navigateToCart: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Order Date: ")
                    .font(.custom("Baloo2-Regular", size: 16))
                Text(order.date)
                    .font(.custom("Baloo2-Bold", size: 16))
                Spacer()
                Text("₱\(String(format: "%.2f", order.total))")
                    .font(.custom("Baloo2-Bold", size: 18))
                    .foregroundColor(Color(hex: "E9351D"))
            }

            Divider()

            ForEach(order.items.sorted(by: <), id: \.key) { item, quantity in
                HStack {
                    Text("\(quantity)x \(item)")
                        .font(.custom("Poppins-Regular", size: 14))
                    Spacer()
                }
            }

            Button("Reorder") {
                reorderItems()
            }
            .font(.custom("Baloo2-Bold", size: 16))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color(hex: "E9351D"))
            .cornerRadius(20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func reorderItems() {
        appManager.clearCart()
        for (itemName, quantity) in order.items {
            if let item = findItemByName(name: itemName) {
                for _ in 0..<quantity {
                    appManager.addToCart(item: item)
                }
            }
        }
        navigateToCart = true
    }

    private func findItemByName(name: String) -> Item? {
        for (_, items) in menuItems {
            if let match = items.first(where: { $0.name == name }) {
                return match
            }
        }
        return nil
    }
}
