//
//  ForgotPasswordView.swift
//  Weekend_Bytes
//
//  Created by STUDENT on 11/13/25.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var message: String?
    @State private var isLoading = false
    @State private var showResetSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Reset Your Password")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Enter your registered email address. We’ll send you a password reset link.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("Error") ? .red : .green)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: sendResetLink) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Send Reset Link")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Send Reset Email
    private func sendResetLink() {
        guard !email.isEmpty else {
            message = "Please enter your email address."
            return
        }

        isLoading = true
        message = nil

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                } else {
                    message = "Password reset link sent to \(email). Please check your inbox."
                    showResetSuccess = true
                }
            }
        }
    }
}
