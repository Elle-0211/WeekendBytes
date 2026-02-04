import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var isLoggedOut = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showingBadgeDescription = false
    @State private var selectedBadgeDescription = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header with Avatar, Name, and Logout
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            // If user just picked a new photo
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                            // Else show image saved in Firestore
                            else if let data = Data(base64Encoded: userVM.profileImageBase64),
                                    let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                            // Default placeholder image
                            else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white.opacity(0.8))
                                    .background(Color.gray.opacity(0.3))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }

                        // Camera button overlay
                        Button(action: { showPhotoPicker = true }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .offset(x: -8, y: -8)
                    }

                    // MARK: - User Info
                    Text(userVM.fullName.isEmpty ? "Loading..." : userVM.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(userVM.email)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    // MARK: - Logout Button
                    Button(action: logout) {
                        Text("Logout")
                            .underline()
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.red)

                // MARK: - Badges Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Badges")
                        .font(.headline)
                        .padding(.horizontal)

                    if userVM.badges.isEmpty {
                        Text("No badges yet. Start ordering to earn your first badge!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(userVM.badges) { badge in
                                Button(action: {
                                    showBadgeDescription(badge)
                                }) {
                                    BadgeView(icon: iconForBadge(badge.title), title: badge.title)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)

                // MARK: - Navigation Links
                List {
                    NavigationLink(destination: AddressesView()) {
                        Text("Addresses")
                    }
                    NavigationLink(destination: PastOrdersView()) {
                        Text("Orders")
                    }
                }
            }
            // MARK: - Lifecycle
            .onAppear {
                userVM.fetchUserData()
            }
            // MARK: - Photo Picker Sheet
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if let image = selectedImage {
                            userVM.updateProfileImage(image)
                        }
                    }
            }
            // MARK: - Logout Navigation
            .navigationDestination(isPresented: $isLoggedOut) {
                SplashScreen()
                    .navigationBarBackButtonHidden(true)
            }
            // MARK: - Badge Description Alert
            .alert(isPresented: $showingBadgeDescription) {
                Alert(
                    title: Text("Badge Unlocked!"),
                    message: Text(selectedBadgeDescription),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Logout Function
    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Badge Description Helper
    private func showBadgeDescription(_ badge: Badge) {
        selectedBadgeDescription = badge.description
        showingBadgeDescription = true
    }

    private func iconForBadge(_ title: String) -> String {
        switch title {
        case "First Byte": return "1.circle"
        case "Loyal Byte": return "trophy"
        case "Weekend Streak": return "flame"
        case "Early Byte": return "clock"
        default: return "star"
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    var icon: String
    var title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Photo Picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
