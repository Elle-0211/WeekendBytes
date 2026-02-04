//
//  AddressesView.swift
//  Weekend_Bytes
//
//  Created by STUDENT on 9/3/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Addresses View
struct AddressesView: View {
    @State private var addresses: [Address] = []
    @State private var showDialog = false
    @State private var isEditing = false
    @State private var selectedAddress: Address? = nil

    // Input fields
    @State private var label = ""
    @State private var street = ""
    @State private var city = ""

    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Addresses")
                .font(.custom("Baloo2-Bold", size: 22))
                .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(addresses) { address in
                        AddressRow(
                            address: address,
                            onEdit: { editAddress(address) },
                            onDelete: { deleteAddress(address) }
                        )
                    }
                }
                .padding()
            }

            Spacer()

            Button("Add New Address") {
                resetForm()
                isEditing = false
                showDialog = true
            }
            .buttonStyle(MainButtonStyle())
            .padding()
        }
        .navigationTitle("Addresses")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDialog) {
            AddressDialog(
                label: $label,
                street: $street,
                city: $city,
                isEditing: $isEditing,
                onSave: saveAddress,
                onCancel: { showDialog = false }
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            loadAddresses()
        }
    }

    // MARK: - Firestore Functions
    private func loadAddresses() {
        guard let user = Auth.auth().currentUser else { return }

        db.collection("users")
            .document(user.uid)
            .collection("addresses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading addresses: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot {
                    self.addresses = snapshot.documents.map { doc in
                        let data = doc.data()
                        return Address(
                            id: doc.documentID,
                            label: data["label"] as? String ?? "",
                            street: data["street"] as? String ?? "",
                            city: data["city"] as? String ?? ""
                        )
                    }
                }
            }
    }

    private func saveAddress() {
        guard let user = Auth.auth().currentUser else { return }

        let newAddress = Address(
            id: selectedAddress?.id ?? UUID().uuidString,
            label: label.trimmingCharacters(in: .whitespacesAndNewlines),
            street: street.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        if isEditing, let selected = selectedAddress {
            let id = selected.id
            db.collection("users")
                .document(user.uid)
                .collection("addresses")
                .document(id)
                .setData([
                    "label": newAddress.label,
                    "street": newAddress.street,
                    "city": newAddress.city
                ]) { error in
                    if let error = error {
                        print("Error updating address: \(error.localizedDescription)")
                    } else {
                        loadAddresses()
                    }
                }
        } else {
            db.collection("users")
                .document(user.uid)
                .collection("addresses")
                .addDocument(data: [
                    "label": newAddress.label,
                    "street": newAddress.street,
                    "city": newAddress.city
                ]) { error in
                    if let error = error {
                        print("Error saving address: \(error.localizedDescription)")
                    } else {
                        loadAddresses()
                    }
                }
        }

        showDialog = false
    }

    private func editAddress(_ address: Address) {
        label = address.label
        street = address.street
        city = address.city
        selectedAddress = address
        isEditing = true
        showDialog = true
    }

    private func deleteAddress(_ address: Address) {
        guard let user = Auth.auth().currentUser else { return }
        let id = address.id

        db.collection("users")
            .document(user.uid)
            .collection("addresses")
            .document(id)
            .delete { error in
                if let error = error {
                    print("Error deleting address: \(error.localizedDescription)")
                } else {
                    loadAddresses()
                }
            }
    }

    private func resetForm() {
        label = ""
        street = ""
        city = ""
        selectedAddress = nil
    }
}

// MARK: - Address Row
struct AddressRow: View {
    let address: Address
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.label)
                        .font(.custom("Baloo2-Bold", size: 18))
                        .foregroundColor(Color(hex: "E9351D"))
                    Text(address.street)
                        .font(.custom("Poppins-Regular", size: 14))
                    Text(address.city)
                        .font(.custom("Poppins-Regular", size: 14))
                }
                Spacer()
                Menu {
                    Button("Edit", action: onEdit)
                    Button(role: .destructive, action: onDelete) {
                        Text("Delete")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Dialog View
struct AddressDialog: View {
    @Binding var label: String
    @Binding var street: String
    @Binding var city: String
    @Binding var isEditing: Bool
    var onSave: () -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Address Details")) {
                    TextField("Type (e.g. Home, Work)", text: $label)
                    TextField("House No. / Street", text: $street)
                    TextField("City", text: $city)
                }
            }
            .navigationTitle(isEditing ? "Edit Address" : "New Address")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
    }
}
