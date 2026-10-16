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
    @State private var showingDeleteConfirmation = false
    
    // Form State
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var address = ""
    
    // Same rule Create Account already uses
    private var isFormIncomplete: Bool {
        fullName.isEmpty || username.isEmpty || email.isEmpty
    }
    
    var body: some View {
        Group {
            if let user = profiles.first {
                if isEditing {
                    // Edit Mode Form
                    Form {
                        Section {
                            avatarHeader(name: fullName)
                        }
                        .listRowBackground(Color.clear)
                        
                        Section(
                            header: Text("Edit Details"),
                            footer: Group {
                                if isFormIncomplete {
                                    Text("Name, username and email are required.")
                                }
                            }
                        ) {
                            TextField("Full Name", text: $fullName)
                            TextField("Username", text: $username).textInputAutocapitalization(.never)
                            TextField("Email Address", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                            TextField("Home Address", text: $address)
                        }
                    }
                } else {
                    // Display Mode List
                    List {
                        Section {
                            avatarHeader(name: user.fullName)
                        }
                        .listRowBackground(Color.clear)
                        
                        Section(header: Text("Account Details")) {
                            LabeledContent("Name", value: user.fullName)
                            LabeledContent("Username", value: "@\(user.username)")
                            LabeledContent("Email", value: user.email)
                        }
                        Section(header: Text("Shipping Address")) {
                            Text(user.homeAddress)
                                .foregroundStyle(.secondary)
                        }
                        Section {
                            // Now asks for confirmation first; the deletion itself is unchanged
                            Button(role: .destructive, action: {
                                showingDeleteConfirmation = true
                            }) {
                                Label("Delete Account", systemImage: "trash")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .confirmationDialog(
                                "Delete your account?",
                                isPresented: $showingDeleteConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Delete Account", role: .destructive) {
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
                                }
                                Button("Cancel", role: .cancel) { }
                            } message: {
                                Text("This permanently deletes your profile, all saved projects and their artwork, and all favourites. This can't be undone.")
                            }
                        }
                    }
                }
            } else {
                // Create Account Form
                Form {
                    Section {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.printPortalAccent)
                            Text("Welcome")
                                .font(.title2.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .accessibilityElement(children: .combine)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Create an Account"), footer: Text("An account is required to submit order enquiries.")) {
                        TextField("Full Name", text: $fullName)
                        TextField("Username", text: $username).textInputAutocapitalization(.never)
                        TextField("Email Address", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                        TextField("Home Address", text: $address)
                    }
                    Section {
                        Button("Create Account") {
                            let newUser = UserProfile(fullName: fullName, username: username, email: email, homeAddress: address)
                            modelContext.insert(newUser)
                            dismiss()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .disabled(isFormIncomplete)
                    }
                    .listRowBackground(
                        Color.printPortalAccent
                            .opacity(isFormIncomplete ? 0.35 : 1)
                    )
                }
            }
        }
        .tint(Color.printPortalAccent)
        .scrollContentBackground(.hidden)
        .background(Color.printPortalBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: isEditing)
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
                    // Save is only blocked while editing and a required field is empty
                    .disabled(isEditing && isFormIncomplete)
                }
            }
        }
    }
    
    // Presentation-only: initials avatar shown at the top of the profile
    private func avatarHeader(name: String) -> some View {
        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
        
        return HStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.printPortalAccent)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.printPortalAccent.opacity(0.25), radius: 8, y: 4)
                if initials.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                } else {
                    Text(initials)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .accessibilityHidden(true)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
