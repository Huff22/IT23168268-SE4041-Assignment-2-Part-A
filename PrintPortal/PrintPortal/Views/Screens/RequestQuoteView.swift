//
//  RequestQuoteView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//

// Views/Screens/RequestQuoteView.swift
import SwiftUI
import SwiftData
import MessageUI

struct RequestQuoteView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let project: DesignProject
    let artworkImage: UIImage?
    
    @State private var quantity: Int = 1
    @State private var requirements: String = "Full-colour printing, double-sided"
    @State private var contactDetails: String = ""
    
    // Mail State
    @State private var isShowingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                // Artwork preview (shown only if an image was passed in)
                if let artworkImage {
                    Section {
                        Image(uiImage: artworkImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                            .padding(.vertical, 4)
                            .accessibilityHidden(true)
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Product Details")) {
                    LabeledContent("Product", value: project.productType.rawValue)
                    LabeledContent(
                        "Size",
                        value: "\(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m"
                    )
                }
                
                Section(header: Text("Order Requirements")) {
                    Stepper(value: $quantity, in: 1...100) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity)")
                                .font(.body.weight(.semibold))
                                .monospacedDigit()
                                .foregroundStyle(Color.printPortalAccent)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Printing requirements")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        TextField("e.g. Matte finish, double-sided", text: $requirements, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 2)
                }
                
                Section(
                    header: Text("Contact Details"),
                    footer: Group {
                        if contactDetails.isEmpty {
                            Text("Add an email or phone number to submit.")
                        }
                    }
                ) {
                    TextField("Email or phone number", text: $contactDetails)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            .tint(Color.printPortalAccent)
            .scrollContentBackground(.hidden)
            .background(Color.printPortalBackground.ignoresSafeArea())
            .animation(.easeInOut(duration: 0.2), value: contactDetails.isEmpty)
            .navigationTitle("Request a Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        saveEnquiry()
                        // Only show mail view if the device is configured for email
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            // Fallback if simulator or no mail account
                            dismiss()
                        }
                    }
                    .bold()
                    .disabled(contactDetails.isEmpty)
                }
            }
            .sheet(isPresented: $isShowingMailView, onDismiss: { dismiss() }) {
                MailView(
                    toRecipient: "orders@printportal.com",
                    subject: "Quote Request: \(project.title)",
                    messageBody: generateEmailBody(),
                    attachmentImage: artworkImage,
                    isShowing: $isShowingMailView,
                    result: $mailResult
                )
            }
            
            .onAppear {
                if let user = profiles.first {
                    contactDetails = user.email // Auto-fill
                }
            }
        }
    }
    
    private func saveEnquiry() {
        let dimensions = "\(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m"
        let enquiry = OrderEnquiry(
            projectTitle: project.title,
            productType: project.productType.rawValue,
            dimensions: dimensions,
            quantity: quantity,
            requirements: requirements,
            contactDetails: contactDetails
        )
        modelContext.insert(enquiry)
    }
    
    private func generateEmailBody() -> String {
        return """
        Hello PrintPortal Team,
        
        I would like to request a quote for the following project:
        
        Project: \(project.title)
        Product: \(project.productType.rawValue)
        Size: \(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m
        Quantity: \(quantity)
        
        Requirements: 
        \(requirements)
        
        Contact: \(contactDetails)
        
        Please find the artwork attached.
        
        Thank you!
        """
    }
}
