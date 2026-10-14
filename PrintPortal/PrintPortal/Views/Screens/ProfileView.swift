//
//  ProfileView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//

// Views/Screens/ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Form State
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var address = ""
    
    var body: some View {
        Group {
            if let user = profiles.first {
                // Show Existing Profile
                List {
                    Section(header: Text("Account Details")) {
                        HStack {
                            Text("Name"); Spacer(); Text(user.fullName).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Username"); Spacer(); Text("@\(user.username)").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Email"); Spacer(); Text(user.email).foregroundColor(.secondary)
                        }
                    }
                    Section(header: Text("Shipping Address")) {
                        Text(user.homeAddress)
                            .foregroundColor(.secondary)
                    }
                    
                    Section {
                        Button(role: .destructive, action: { modelContext.delete(user) }) {
                            Text("Sign Out (Delete Account)")
                        }
                    }
                }
                .navigationTitle("Profile")
            } else {
                // Create Account Form
                Form {
                    Section(header: Text("Create an Account"), footer: Text("An account is required to submit order enquiries.")) {
                        TextField("Full Name", text: $fullName)
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Home Address", text: $address)
                    }
                    
                    Section {
                        Button("Create Account") {
                            let newUser = UserProfile(fullName: fullName, username: username, email: email, homeAddress: address)
                            modelContext.insert(newUser)
                            dismiss() // If opened via a sheet, close it
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.printPortalAccent)
                        .disabled(fullName.isEmpty || username.isEmpty || email.isEmpty)
                    }
                }
                .navigationTitle("Welcome")
            }
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
    }
}
