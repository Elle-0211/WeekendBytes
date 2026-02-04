import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore


// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var navigateToOnboarding = false
    
    var body: some View {
        if navigateToOnboarding {
            OnboardingView()
        } else {
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "F9EB05"))
                        .frame(width: 200, height: 200)
                    
                    Image("Hotdog")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 330)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                }
                
                Text("Weekend\nBytes")
                    .font(.custom("Baloo2-Bold", size: 40))
                    .multilineTextAlignment(.center)
                    .tracking(8)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                
                Spacer()
                
                Button(action: {
                    navigateToOnboarding = true
                }) {
                    Text("GET STARTED")
                        .font(.custom("Baloo2-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "E9351D"))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Onboarding Screen
struct OnboardingView: View {
    @State private var goToAuth = false
    @State private var initialAuthTab: Int = 0
    
    var body: some View {
        if goToAuth {
            AuthSelectionView(initialTab: initialAuthTab)
        } else {
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "F9EB05"))
                        .frame(width: 200, height: 200)
                    
                    Image("Picnic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 157, height: 157)
                        .foregroundColor(.white)
                }
                
                Text("Your Food Adventure\nStarts Here")
                    .font(.custom("Baloo2-Bold", size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.top, 16)
                
                Text("Create an Account to discover affordable dining and quick bites at your fingertips.")
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .foregroundColor(.black)
                    .padding(.top, 8)
                
                Spacer()
                
                Button("Sign up") {
                    initialAuthTab = 0
                    goToAuth = true
                }
                .buttonStyle(MainButtonStyle())
                .padding(.horizontal, 40)
                
                Button("Log in") {
                    initialAuthTab = 1
                    goToAuth = true
                }
                .buttonStyle(MainButtonStyle())
                .padding(.horizontal, 40)
                
                Spacer().frame(height: 50)
            }
        }
    }
}

// MARK: - Auth Selection View
struct AuthSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: Int
    @State private var loggedIn = false
    
    init(initialTab: Int) {
        self._selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        if loggedIn {
            DashboardView()
        } else {
            NavigationView {
                VStack {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(hex: "F3F3F3"))
                            .frame(height: 180)
                        
                        Image("Picnic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .offset(y: 40)
                    }
                    
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Button(action: { selectedTab = 0 }) {
                                VStack {
                                    Text("Sign up")
                                        .font(.custom("Baloo2-Bold", size: 20))
                                        .foregroundColor(selectedTab == 0 ? Color(hex: "E9351D") : .gray)
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(selectedTab == 0 ? Color(hex: "E9351D") : .clear)
                                }
                            }
                            Spacer()
                            Button(action: { selectedTab = 1 }) {
                                VStack {
                                    Text("Log in")
                                        .font(.custom("Baloo2-Bold", size: 20))
                                        .foregroundColor(selectedTab == 1 ? Color(hex: "E9351D") : .gray)
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(selectedTab == 1 ? Color(hex: "E9351D") : .clear)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 40)
                        
                        if selectedTab == 0 {
                            SignupForm { loggedIn = true }
                        } else {
                            LoginForm { loggedIn = true }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -40)
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// MARK: - Signup Form
struct SignupForm: View {
    var onSuccess: () -> Void
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Group {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Full Name")
                    TextField("Enter your full name", text: $fullName)
                        .textFieldStyle(AuthTextFieldStyle())
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email Address")
                    TextField("Enter a valid email address", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: email) {
                            email = email.lowercased()
                        }
                        .textFieldStyle(AuthTextFieldStyle())
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                    SecureField("Create your Password", text: $password)
                        .textFieldStyle(AuthTextFieldStyle())
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Confirm Password")
                    SecureField("Re-enter your Password", text: $confirmPassword)
                        .textFieldStyle(AuthTextFieldStyle())
                }
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Sign Up") {
                register()
            }
            .buttonStyle(MainButtonStyle())

            Button(action: { signUpWithGoogle() }) {
                HStack(spacing: 10) {
                    Image("googleLogo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign up with Google")
                        .font(.custom("Baloo2-Bold", size: 18))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.gray, lineWidth: 1))
            }
        }
        .padding()
    }

    // Register and save user to Firestore
    private func register() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let user = result?.user else {
                errorMessage = "User not found after registration"
                return
            }

            // Save user to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "fullName": fullName,
                "email": user.email ?? "",
                "createdAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("Error saving user: \(error.localizedDescription)")
                } else {
                    print("User added successfully to Firestore!")
                }
            }

            onSuccess()
        }
    }

    private func signUpWithGoogle() {
        signInWithGoogle(onSuccess: onSuccess, errorMessage: $errorMessage)
    }
}

// MARK: - Login Form
struct LoginForm: View {
    var onSuccess: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showForgotPasswordSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Email Address")
                TextField("Enter a valid email address", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: email) {
                        email = email.lowercased()
                    }
                    .textFieldStyle(AuthTextFieldStyle())
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Password")
                SecureField("Enter your Password", text: $password)
                    .textFieldStyle(AuthTextFieldStyle())
                HStack {
                    Spacer()
                    Button("Forgot Password?") {showForgotPasswordSheet = true}
                        .font(.custom("Baloo2-Regular", size: 14))
                        .foregroundColor(Color(hex: "E9351D"))
                        .sheet(isPresented: $showForgotPasswordSheet) {
                                ForgotPasswordView()
                    }
                }
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Log in") {
                login()
            }
            .buttonStyle(MainButtonStyle())

            Button(action: { loginWithGoogle() }) {
                HStack(spacing: 10) {
                    Image("googleLogo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.custom("Baloo2-Bold", size: 18))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.gray, lineWidth: 1))
            }
        }
        .padding()
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                onSuccess()
            }
        }
    }

    private func loginWithGoogle() {
        signInWithGoogle(onSuccess: onSuccess, errorMessage: $errorMessage)
    }
}

// MARK: - Shared Google Sign-In Function (with Firestore)
private func signInWithGoogle(onSuccess: @escaping () -> Void, errorMessage: Binding<String?>) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        errorMessage.wrappedValue = "Missing Google Client ID"
        return
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        errorMessage.wrappedValue = "Unable to find root view controller"
        return
    }

    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
        if let error = error {
            errorMessage.wrappedValue = error.localizedDescription
            return
        }

        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
            errorMessage.wrappedValue = "Google sign-in failed"
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                errorMessage.wrappedValue = error.localizedDescription
                return
            }

            guard let firebaseUser = authResult?.user else { return }

            // Save Google user to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(firebaseUser.uid).setData([
                "fullName": user.profile?.name ?? "",
                "email": firebaseUser.email ?? "",
                "createdAt": Timestamp()
            ], merge: true) { error in
                if let error = error {
                    print("Error saving Google user: \(error.localizedDescription)")
                } else {
                    print("Google user added successfully to Firestore!")
                }
            }

            onSuccess()
        }
    }
}
