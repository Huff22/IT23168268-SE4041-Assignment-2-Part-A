//
//  OnboardingView..swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Views/Screens/OnboardingView.swift
import SwiftUI

struct OnboardingStep {
    let title: String
    let subtitle: String
    let iconName: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0
    
    let steps = [
        OnboardingStep(title: "Visualize Your Prints", subtitle: "See exactly how your signs and banners look in the real world before you order.", iconName: "arkit"),
        OnboardingStep(title: "Design with Precision", subtitle: "Upload your custom artwork and map it perfectly onto accurate 3D models.", iconName: "ruler.fill"),
        OnboardingStep(title: "Request a Quote", subtitle: "Happy with the preview? Send an enquiry to us directly from the app.", iconName: "paperplane.fill")
    ]
    
    var body: some View {
        VStack {
            // Top Bar: Skip Button
            HStack {
                Spacer()
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.headline.bold())
                .foregroundColor(.printPortalAccent)
                .padding()
            }
            
            Spacer()
            
            // Central Content
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: steps[index].iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.printPortalAccent)
                            .padding(.bottom, 30)
                        
                        Text(steps[index].title)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text(steps[index].subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            
            Spacer()
            
            // Custom Bottom Navigation Bar
            HStack {
                // Back Button
                Button(action: {
                    withAnimation { if currentStep > 0 { currentStep -= 1 } }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(currentStep > 0 ? .printPortalAccent : .clear)
                        .padding(16)
                        .background(Circle().stroke(currentStep > 0 ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1))
                }
                .disabled(currentStep == 0)
                
                Spacer()
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.printPortalAccent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                // Forward / Start Button
                Button(action: {
                    withAnimation {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                        } else {
                            finishOnboarding()
                        }
                    }
                }) {
                    Image(systemName: currentStep == steps.count - 1 ? "checkmark" : "arrow.right")
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Circle().fill(Color.printPortalAccent))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
    }
    
    private func finishOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}
