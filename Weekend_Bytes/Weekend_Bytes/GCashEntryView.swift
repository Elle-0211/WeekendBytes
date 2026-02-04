//
//  GCashEntryView.swift
//  Weekend_Bytes
//
//  Created by STUDENT on 11/17/25.
//

import SwiftUI

struct GCashEntryView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var gcashNumber: String = ""
    @State private var isSaving: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Link GCash Number")
                .font(.custom("Baloo2-Bold", size: 22))
            
            TextField("Enter GCash number", text: $gcashNumber)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            
            Button(action: saveGCash) {
                if isSaving {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0057E4"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                } else {
                    Text("Save")
                        .font(.custom("Baloo2-Bold", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0057E4"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            .disabled(isSaving)
            
            Spacer()
        }
        .padding()
        .onAppear {
            gcashNumber = userVM.gcashNumber
        }
    }
    
    private func saveGCash() {
        guard !gcashNumber.isEmpty else { return }
        isSaving = true
        
        userVM.updateGcashNumber(gcashNumber) { success, message in
            print(message ?? "")
            isSaving = false
            if success {
                dismiss()
            }
        }
    }
}
