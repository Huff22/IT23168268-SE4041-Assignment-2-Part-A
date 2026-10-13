//
//  MailView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Services/Networking/MailView.swift
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let toRecipient: String
    let subject: String
    let messageBody: String
    let attachmentImage: UIImage?
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { isShowing = false }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([toRecipient])
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        
        if let image = attachmentImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            vc.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "artwork.jpg")
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
