//
// DeliveryView.swift
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Equatable wrapper for CLLocationCoordinate2D
struct EquatableCoordinate: Equatable {
    var latitude: Double
    var longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Delivery View
struct DeliveryView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - States
    @State private var navigateToOrderPlaced = false
    @State private var deliveryAddress: String = ""
    @State private var isContactless: Bool = false
    @State private var selectedPaymentMethod: String = "Cash on Delivery"
    @State private var showGCashEntry = false
    @State private var isProcessingPayment = false
    @State private var paymentError: String? = nil
    @State private var geocodeWorkItem: DispatchWorkItem?

    // Keep the last geocoded street/city
    @State private var lastGeocodedStreet: String = ""
    @State private var lastGeocodedCity: String = ""

    // Delivery Option
    @State private var selectedDeliveryOption: String = "Standard"
    @State private var showSchedulePicker = false
    @State private var scheduledDate = Date()

    // Map States (Manila default)
    @State private var pinCoordinate = EquatableCoordinate(CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842))
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Firestore
    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Address and Delivery")
                    .font(.custom("Baloo2-Bold", size: 22))
                    .padding(.top, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: - Delivery Address Section
                        VStack(alignment: .leading) {
                            Text("Delivery Address")
                                .font(.custom("Baloo2-Bold", size: 16))

                            MapViewRepresentable(region: $region, pinCoordinate: $pinCoordinate)
                                .frame(height: 200)
                                .cornerRadius(10)

                            // Text field: geocode on commit, debounce on change
                            TextField("Enter your delivery address", text: $deliveryAddress, onCommit: {
                                geocodeAddress(deliveryAddress)
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: deliveryAddress) { oldValue, newValue in
                                geocodeWorkItem?.cancel()
                                let workItem = DispatchWorkItem {
                                    geocodeAddress(newValue)
                                }
                                geocodeWorkItem = workItem
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                            }

                            Toggle("Contactless Delivery (GCash required)", isOn: $isContactless)
                                .font(.custom("Poppins-Regular", size: 14))
                                .onChange(of: isContactless) { _, newValue in
                                    if newValue {
                                        selectedPaymentMethod = "GCash"
                                    }
                                }
                        }

                        // MARK: - Delivery Options
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Delivery Options")
                                .font(.custom("Baloo2-Bold", size: 16))

                            DeliveryOptionButton(
                                title: "ASAP (25 min)",
                                isSelected: selectedDeliveryOption == "Standard"
                            ) {
                                selectedDeliveryOption = "Standard"
                                appManager.updateTotals()
                            }

                            DeliveryOptionButton(
                                title: "Scheduled",
                                isSelected: selectedDeliveryOption == "Scheduled"
                            ) {
                                selectedDeliveryOption = "Scheduled"
                                showSchedulePicker = true
                            }
                        }
                        .sheet(isPresented: $showSchedulePicker) {
                            SchedulePickerView(selectedDate: $scheduledDate, selectedOption: $selectedDeliveryOption)
                        }

                        // MARK: - Payment Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Payment Method")
                                .font(.custom("Baloo2-Bold", size: 16))

                            HStack {
                                Text(selectedPaymentMethod)
                                    .font(.custom("Baloo2-Regular", size: 16))
                                Spacer()
                                NavigationLink("Change") {
                                    PaymentSelectionView(selectedMethod: $selectedPaymentMethod)
                                }
                                .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }

                        // MARK: - Order Summary
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
                            Divider()
                            HStack {
                                Text("TOTAL")
                                    .font(.custom("Baloo2-Bold", size: 18))
                                Spacer()
                                Text("₱ \(String(format: "%.2f", appManager.total))")
                                    .font(.custom("Baloo2-Bold", size: 18))
                            }
                        }
                        .padding(.vertical)

                        if let error = paymentError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top, 4)
                        }
                    }
                    .padding()

                    // MARK: - Place Order Button
                    if isProcessingPayment {
                        ProgressView("Processing Payment...")
                            .padding()
                    } else {
                        Button(action: handlePlaceOrder) {
                            Text("Place Order")
                                .font(.custom("Baloo2-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "E9351D"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(appManager.cartItems.isEmpty)
                    }
                }
            }
            .navigationDestination(isPresented: $showGCashEntry) {
                GCashEntryView()
                    .environmentObject(userVM)
            }
            .navigationDestination(isPresented: $navigateToOrderPlaced) {
                OrderPlacedView()
            }
            .onAppear {
                loadSavedAddress()
            }
            .onChange(of: pinCoordinate) { _, newCoord in
                reverseGeocodeCoordinate(newCoord.coordinate)
            }
        }
    }

    // MARK: - Place Order Logic
    private func handlePlaceOrder() {
        if selectedPaymentMethod == "GCash" && userVM.gcashNumber.isEmpty {
            showGCashEntry = true
            return
        }

        isProcessingPayment = true
        paymentError = nil

        appManager.saveOrder { success, errorMessage in
            DispatchQueue.main.async {
                isProcessingPayment = false
                if success {
                    saveAddressIfNeeded()
                    appManager.clearCart()
                    UserDefaults.standard.removeObject(forKey: "activePromo")
                    navigateToOrderPlaced = true
                } else {
                    paymentError = errorMessage
                }
            }
        }
    }

    // MARK: - Load saved address (autofill)
    private func loadSavedAddress() {
        guard let user = Auth.auth().currentUser else { return }

        db.collection("users").document(user.uid).collection("addresses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading addresses: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents, !docs.isEmpty else { return }

                let homeDoc = docs.first { ($0.data()["label"] as? String ?? "").lowercased() == "home" }
                let chosenDoc = homeDoc ?? docs.first!

                let data = chosenDoc.data()
                let street = data["street"] as? String ?? ""
                let city = data["city"] as? String ?? ""
                let combined = [street, city].filter { !$0.isEmpty }.joined(separator: ", ")

                DispatchQueue.main.async {
                    self.deliveryAddress = combined
                }

                if !combined.isEmpty {
                    geocodeAddress(combined)
                }
            }
    }

    // MARK: - Save address if needed
    private func saveAddressIfNeeded() {
        guard let user = Auth.auth().currentUser else { return }

        // We need street & city (from the last geocode). If not available, attempt a simple split fallback.
        var streetToSave = lastGeocodedStreet
        var cityToSave = lastGeocodedCity

        if streetToSave.isEmpty && cityToSave.isEmpty {
            // fallback: try splitting typed deliveryAddress roughly
            let parts = deliveryAddress
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if parts.count >= 2 {
                cityToSave = String(parts.last ?? "")
                streetToSave = parts.dropLast().joined(separator: ", ")
            } else {
                streetToSave = deliveryAddress
                cityToSave = ""
            }
        }

        let addrColl = db.collection("users").document(user.uid).collection("addresses")
        addrColl.getDocuments { snapshot, error in
            if let error = error {
                print("Error reading addresses: \(error.localizedDescription)")
                return
            }

            let docs = snapshot?.documents ?? []

         
            if docs.isEmpty || !docs.contains(where:{ ($0.data()["label"] as? String ?? "").lowercased() == "home" }) {
                addrColl.addDocument(data: [
                    "label": "Home",
                    "street": streetToSave,
                    "city": cityToSave
                ]) { err in
                    if let err = err {
                        print("Error saving Home address: \(err.localizedDescription)")
                    } else {
                        print("Saved Home address.")
                    }
                }
            }
        }
    }
    // MARK: - Geocode address string
    private func geocodeAddress(_ address: String) {
        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let err = error { print("Geocode error:", err.localizedDescription); return }
            guard let placemark = placemarks?.first, let location = placemark.location else { return }

            DispatchQueue.main.async {
                self.pinCoordinate = EquatableCoordinate(location.coordinate)
                self.region.center = location.coordinate
            }

            // Extract street/city
            var streetParts: [String] = []
            if let subThoroughfare = placemark.subThoroughfare { streetParts.append(subThoroughfare) }
            if let thoroughfare = placemark.thoroughfare { streetParts.append(thoroughfare) }
            if let subLocality = placemark.subLocality { streetParts.append(subLocality) }
            if let subAdministrativeArea = placemark.subAdministrativeArea, streetParts.isEmpty {
                streetParts.append(subAdministrativeArea)
            }
            let street = streetParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let city = (placemark.locality ?? placemark.administrativeArea ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            DispatchQueue.main.async {
                self.lastGeocodedStreet = street
                self.lastGeocodedCity = city
                let combined = [street, city].filter { !$0.isEmpty }.joined(separator: ", ")
                if !combined.isEmpty {
                    self.deliveryAddress = combined
                }
            }
        }
    }

    // MARK: - Reverse geocode coordinate
    private func reverseGeocodeCoordinate(_ coord: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let err = error { print("Reverse geocode error:", err.localizedDescription); return }
            guard let placemark = placemarks?.first else { return }

            var streetParts: [String] = []
            if let subThoroughfare = placemark.subThoroughfare { streetParts.append(subThoroughfare) }
            if let thoroughfare = placemark.thoroughfare { streetParts.append(thoroughfare) }
            if let subLocality = placemark.subLocality { streetParts.append(subLocality) }
            let street = streetParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let city = (placemark.locality ?? placemark.administrativeArea ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            DispatchQueue.main.async {
                self.lastGeocodedStreet = street
                self.lastGeocodedCity = city
                let combined = [street, city].filter { !$0.isEmpty }.joined(separator: ", ")
                if !combined.isEmpty {
                    self.deliveryAddress = combined
                }
            }
        }
    }
}

// MARK: - Schedule Picker View
struct SchedulePickerView: View {
    @Binding var selectedDate: Date
    @Binding var selectedOption: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Schedule Your Delivery")
                .font(.custom("Baloo2-Bold", size: 18))
                .padding(.top)

            DatePicker(
                "Select Date & Time",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .padding()

            HStack(spacing: 20) {
                Button("Cancel") {
                    selectedOption = "Standard"
                }
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10)

                Button("Confirm") {
                    // Just dismiss
                }
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "E9351D"))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - MapViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: EquatableCoordinate

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinate.coordinate
        annotation.title = "Delivery Location"
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinate.coordinate
        annotation.title = "Delivery Location"
        uiView.addAnnotation(annotation)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        init(parent: MapViewRepresentable) { self.parent = parent }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.pinCoordinate = EquatableCoordinate(coordinate)
            parent.region.center = coordinate

            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Delivery Location"
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: - OrderPlacedView
struct OrderPlacedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            Text("Order Placed!")
                .font(.custom("Baloo2-Bold", size: 30))
            Text("Thank you for your purchase. Your order is on its way.")
                .font(.custom("Poppins-Regular", size: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink(destination: DashboardView()) {
                Text("Back to Home")
                    .font(.custom("Baloo2-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "E9351D"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - DeliveryOptionButton
struct DeliveryOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("Baloo2-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(hex: "E9351D") : Color.gray, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

// MARK: - PaymentSelectionView
struct PaymentSelectionView: View {
    @Binding var selectedMethod: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Payment Method")
                .font(.custom("Baloo2-Bold", size: 20))

            PaymentOptionButton(title: "Cash on Delivery", isSelected: selectedMethod == "Cash on Delivery") {
                selectedMethod = "Cash on Delivery"
            }
            PaymentOptionButton(title: "GCash", isSelected: selectedMethod == "GCash") {
                selectedMethod = "GCash"
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - PaymentOptionButton
struct PaymentOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("Baloo2-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? Color(hex: "E9351D") : .gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(hex: "E9351D") : Color.gray, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
