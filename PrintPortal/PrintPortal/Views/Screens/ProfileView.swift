// Views/Screens/ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query private var projects: [DesignProject]
    @Query private var favorites: [FavoriteProduct]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    
    // Form State
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var address = ""
    
    var body: some View {
        Group {
            if let user = profiles.first {
                if isEditing {
                    // Edit Mode Form
                    Form {
                        Section(header: Text("Edit Details")) {
                            TextField("Full Name", text: $fullName)
                            TextField("Username", text: $username).autocapitalization(.none)
                            TextField("Email Address", text: $email).keyboardType(.emailAddress).autocapitalization(.none)
                            TextField("Home Address", text: $address)
                        }
                    }
                } else {
                    // Display Mode List
                    List {
                        Section(header: Text("Account Details")) {
                            HStack { Text("Name"); Spacer(); Text(user.fullName).foregroundColor(.secondary) }
                            HStack { Text("Username"); Spacer(); Text("@\(user.username)").foregroundColor(.secondary) }
                            HStack { Text("Email"); Spacer(); Text(user.email).foregroundColor(.secondary) }
                        }
                        Section(header: Text("Shipping Address")) {
                            Text(user.homeAddress).foregroundColor(.secondary)
                        }
                        Section {
                                                    Button(role: .destructive, action: {
                                                        // 1. Delete the user profile
                                                        modelContext.delete(user)
                                                        
                                                        // 2. Delete all saved projects
                                                        for project in projects {
                                                            if let filename = project.artworkFilename {
                                                                ArtworkStorageService.shared.deleteImage(filename: filename)
                                                            }
                                                            modelContext.delete(project)
                                                        }
                                                        
                                                        // 3. Delete all favorites
                                                        for favorite in favorites {
                                                            modelContext.delete(favorite)
                                                        }
                                                        
                                                        // 4. Reset the form state so it's blank when they return
                                                        fullName = ""
                                                        username = ""
                                                        email = ""
                                                        address = ""
                                                        isEditing = false
                                                        
                                                    }) {
                                                        Text("Delete Account")
                                                    }
                                                }
                    }
                }
            } else {
                // Create Account Form
                Form {
                    Section(header: Text("Create an Account"), footer: Text("An account is required to submit order enquiries.")) {
                        TextField("Full Name", text: $fullName)
                        TextField("Username", text: $username).autocapitalization(.none)
                        TextField("Email Address", text: $email).keyboardType(.emailAddress).autocapitalization(.none)
                        TextField("Home Address", text: $address)
                    }
                    Section {
                        Button("Create Account") {
                            let newUser = UserProfile(fullName: fullName, username: username, email: email, homeAddress: address)
                            modelContext.insert(newUser)
                            dismiss()
                        }
                        .bold().frame(maxWidth: .infinity, alignment: .center).foregroundColor(.printPortalAccent)
                        .disabled(fullName.isEmpty || username.isEmpty || email.isEmpty)
                    }
                }
            }
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle(profiles.isEmpty ? "Welcome" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if profiles.first != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            // Save changes
                            profiles.first?.fullName = fullName
                            profiles.first?.username = username
                            profiles.first?.email = email
                            profiles.first?.homeAddress = address
                        } else {
                            // Load existing data into fields before editing
                            fullName = profiles.first?.fullName ?? ""
                            username = profiles.first?.username ?? ""
                            email = profiles.first?.email ?? ""
                            address = profiles.first?.homeAddress ?? ""
                        }
                        isEditing.toggle()
                    }
                    .bold()
                }
            }
        }
    }
}
