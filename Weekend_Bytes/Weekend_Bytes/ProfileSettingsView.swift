import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSettingsView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var mobileNumber = ""
    @State private var email = ""
    
    @State private var activeAlert: ActiveAlert?
    @State private var connectedAccounts: [String] = ["Google"]
    
    enum ActiveAlert: Identifiable {
        case deleteAccount, deletePayment, deleteConnectedAccount
        var id: Int { hashValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 15) {
                ZStack {
                    if let data = Data(base64Encoded: userVM.profileImageBase64),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 6)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 6)
                    }
                }
                
                Text("My Profile")
                    .font(.custom("Baloo2-Bold", size: 24))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.8, green: 0.27, blue: 0.17)) // original red header
            
            // MARK: - Scroll Content
            ScrollView {
                VStack(spacing: 20) {
                    personalInfoSection
                    Divider().padding(.vertical, 10)
                    
                    emailSection
                    Divider().padding(.vertical, 10)
                    
                    paymentsSection
                    Divider().padding(.vertical, 10)
                    
                    connectedAccountsSection
                    Divider().padding(.vertical, 10)
                    
                    accountManagementSection
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .deleteAccount:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        userVM.deleteUserAccount { success, message in
                        if success {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("UserDeletedAccount"),
                                object: nil
                            )
                        } else {
                            print(message ?? "Unknown error")
                        }
                    }
                },
                    secondaryButton: .cancel()
                )
            case .deletePayment:
                return Alert(
                    title: Text("Delete Payment Method?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        userVM.deleteGcashNumber { success, message in
                            if success {
                                print("GCash number deleted successfully")
                            } else {
                                print(message ?? "Failed to delete GCash number")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .deleteConnectedAccount:
                return Alert(
                    title: Text("Disconnect Account?"),
                    message: Text("Are you sure you want to disconnect this account?"),
                    primaryButton: .destructive(Text("Disconnect")) {
                        if !connectedAccounts.isEmpty { connectedAccounts.removeLast() }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            userVM.fetchUserData()
            firstName = userVM.firstName
            lastName = userVM.lastName
            mobileNumber = userVM.mobileNumber
            email = userVM.email
        }
    }
    
    // MARK: - Sections
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabelTextField(label: "First Name", text: $firstName)
            LabelTextField(label: "Last Name", text: $lastName)
            LabelTextField(label: "Mobile Number", text: $mobileNumber)
            saveButton(action: saveProfile)
        }
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.black)
            TextField("", text: $email)
                .disabled(true)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Payments")
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.black)
            
            HStack {
                Image(systemName: "g.circle.fill").font(.system(size: 28)).foregroundColor(.blue)
                Text(userVM.gcashNumber.isEmpty ? "No GCash linked" : maskedGcashNumber(userVM.gcashNumber))
                    .font(.custom("Baloo2-Regular", size: 14))
                    .foregroundColor(.gray)
                Spacer()
                if userVM.gcashNumber.isEmpty {
                    NavigationLink("Add", destination: GCashEntryView().environmentObject(userVM))
                        .font(.custom("Baloo2-Bold", size: 14))
                        .foregroundColor(.black)
                } else {
                    Button("Delete") { activeAlert = .deletePayment }
                        .font(.custom("Baloo2-Bold", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    private var connectedAccountsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connected Accounts")
                .font(.custom("Baloo2-Bold", size: 16))
                .foregroundColor(.black)
            
            ForEach(connectedAccounts, id: \.self) { account in
                HStack {
                    Image("googleLogo").resizable().frame(width: 20, height: 20)
                    Text(account).font(.custom("Baloo2-Bold", size: 16)).foregroundColor(.black)
                    Spacer()
                    Button(action: { activeAlert = .deleteConnectedAccount }) {
                        Image(systemName: "xmark").foregroundColor(.black)
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }
        }
    }
    
    private var accountManagementSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account Management")
                .font(.custom("Baloo2-Bold", size: 14))
                .foregroundColor(.black)
            
            Text("You can delete your account and personal data associated with it")
                .font(.custom("Baloo2-Regular", size: 12))
                .foregroundColor(.gray)
            
            Button(action: { activeAlert = .deleteAccount }) {
                Text("Delete Account")
                    .font(.custom("Baloo2-Bold", size: 14))
                    .frame(width: 160, height: 36)
                    .foregroundColor(.black)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Helpers
    private func maskedGcashNumber(_ number: String) -> String {
        let prefix = String(number.prefix(4))
        let suffix = String(number.suffix(4))
        return "\(prefix)****\(suffix)"
    }
    
    private func saveButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Save")
                .font(.custom("Baloo2-Regular", size: 14))
                .frame(width: 90, height: 36)
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
        }
        .padding(.top, 8)
    }
    
    private func saveProfile() {
        let combinedName = "\(firstName) \(lastName)"
        userVM.updateProfile(fullName: combinedName, mobileNumber: mobileNumber) { _, _ in
            userVM.fetchUserData()
        }
    }
}

// MARK: - Custom Components
struct LabelTextField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.custom("Baloo2-Bold", size: 12))
                .foregroundColor(.black)
            TextField("", text: $text)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .font(.custom("Baloo2-Regular", size: 14))
        }
    }
}

