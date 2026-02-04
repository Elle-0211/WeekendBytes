//
//  UserViewModel.swift
//  Weekend_Bytes
//
//  Created by STUDENT on 10/14/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct Badge: Identifiable {
    var id: String
    var title: String
    var description: String
}

class UserViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var mobileNumber: String = ""
    @Published var email: String = ""
    @Published var profileImageBase64: String = ""
    @Published var badges: [Badge] = []
    @Published var isLoading = false
    @Published var gcashNumber: String = ""
    
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async { self?.isLoading = false }
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                let full = data["fullName"] as? String ?? ""
                let components = full.split(separator: " ")
                self?.firstName = components.first.map(String.init) ?? ""
                self?.lastName = components.dropFirst().joined(separator: " ")
                self?.fullName = full
                self?.email = data["email"] as? String ?? ""
                self?.mobileNumber = data["mobileNumber"] as? String ?? ""
                self?.profileImageBase64 = data["profileImageBase64"] as? String ?? ""
                self?.gcashNumber = data["gcashNumber"] as? String ?? ""
            }

            self?.fetchBadges()
        }
    }
    
    func fetchBadges() {
        guard let user = Auth.auth().currentUser else { return }
        db.collection("users").document(user.uid).collection("badges").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching badges: \(error.localizedDescription)")
                return
            }

            let loadedBadges = snapshot?.documents.compactMap { doc -> Badge? in
                let data = doc.data()
                let title = data["title"] as? String ?? ""
                
                let description: String
                switch title {
                case "First Byte": description = "Awarded for your very first order!"
                case "Loyal Byte": description = "You’ve been ordering for a month or more!"
                case "Weekend Streak": description = "Ordered on consecutive weekend days!"
                case "Early Byte": description = "Placed an order in the morning!"
                default: description = "Special achievement unlocked!"
                }
                return Badge(id: doc.documentID, title: title, description: description)
            } ?? []

            DispatchQueue.main.async {
                self?.badges = loadedBadges
            }
        }
    }
    
    func updateProfile(fullName: String, mobileNumber: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let updateData: [String: Any] = [
            "fullName": fullName,
            "mobileNumber": mobileNumber
        ]
        db.collection("users").document(user.uid).updateData(updateData) { error in
            if let error = error {
                completion(false, "Failed to update: \(error.localizedDescription)")
            } else {
                completion(true, "Profile updated successfully.")
            }
        }
    }

    func updateProfileImage(_ image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let base64String = imageData.base64EncodedString()
        
        db.collection("users").document(user.uid).updateData([
            "profileImageBase64": base64String
        ]) { [weak self] error in
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.profileImageBase64 = base64String
                }
            }
        }
    }
    
    // MARK: - Save or Update and Delete GCash Number
    func updateGcashNumber(_ number: String, completion: @escaping (Bool, String?) -> Void) {
        guard !number.isEmpty else {
            completion(false, "GCash number cannot be empty")
            return
        }

        guard let user = Auth.auth().currentUser else {
            completion(false, "User not logged in")
            return
        }

        let updateData: [String: Any] = ["gcashNumber": number]

        db.collection("users").document(user.uid).updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Failed to update GCash number: \(error.localizedDescription)")
                } else {
                    self?.gcashNumber = number
                    completion(true, "GCash number updated successfully")
                }
            }
        }
    }
    func deleteGcashNumber(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "User not logged in")
            return
        }
        
        db.collection("users").document(user.uid)
            .updateData(["gcashNumber": FieldValue.delete()]) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, "Failed to delete GCash number: \(error.localizedDescription)")
                    } else {
                        self?.gcashNumber = ""
                        completion(true, "GCash number deleted successfully")
                    }
                }
            }
    }
    
    // MARK: - Delete Account
    func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "User not logged in")
            return
        }

        let uid = user.uid

        // 1. Delete Firestore user document
        db.collection("users").document(uid).delete { [weak self] error in
            if let error = error {
                completion(false, "Failed to delete user data: \(error.localizedDescription)")
                return
            }

            // 2. Delete Firebase Auth user
            user.delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, "Failed to delete account: \(error.localizedDescription)")
                    } else {
                        // Clear any locally stored data
                        self?.fullName = ""
                        self?.firstName = ""
                        self?.lastName = ""
                        self?.email = ""
                        self?.mobileNumber = ""
                        self?.profileImageBase64 = ""
                        self?.gcashNumber = ""
                        self?.badges = []

                        // 3. Sign out globally
                        try? Auth.auth().signOut()

                        // 4. Notify App to redirect user to Splash/Login
                        NotificationCenter.default.post(name: NSNotification.Name("UserDeletedAccount"), object: nil)

                        completion(true, nil)
                    }
                }
            }
        }
    }
}
