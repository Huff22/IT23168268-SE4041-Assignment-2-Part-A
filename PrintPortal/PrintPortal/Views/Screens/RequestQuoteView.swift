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
                Section(header: Text("Product Details")) {
                    HStack {
                        Text("Product")
                        Spacer()
                        Text(project.productType.rawValue).foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Size")
                        Spacer()
                        Text("\(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Order Requirements")) {
                    Stepper(value: $quantity, in: 1...100) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity)").bold()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Printing requirements").font(.caption).foregroundColor(.secondary)
                        TextField("e.g. Matte finish, double-sided", text: $requirements, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section(header: Text("Contact Details")) {
                    TextField("Email or phone number", text: $contactDetails)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
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
