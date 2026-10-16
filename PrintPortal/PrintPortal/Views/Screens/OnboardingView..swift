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
        OnboardingStep(title: "Request a Quote", subtitle: "Happy with the preview? Send us an enquiry directly from the app.", iconName: "paperplane.fill")
    ]
    
    var body: some View {
        VStack {
            // Top Bar: Skip Button
            HStack {
                Spacer()
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.headline)
                .foregroundStyle(Color.printPortalAccent)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            
            Spacer()
            
            // Central Content
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.printPortalAccent.opacity(0.1))
                                .frame(width: 200, height: 200)
                            Circle()
                                .strokeBorder(Color.printPortalAccent.opacity(0.15), lineWidth: 1)
                                .frame(width: 200, height: 200)
                            Image(systemName: steps[index].iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundStyle(Color.printPortalAccent)
                        }
                        .padding(.bottom, 24)
                        .accessibilityHidden(true)
                        
                        Text(steps[index].title)
                            .font(.title.weight(.bold))
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(steps[index].subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
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
                        .font(.headline)
                        .foregroundStyle(Color.printPortalAccent)
                        .frame(width: 52, height: 52)
                        .background(Circle().strokeBorder(Color(UIColor.separator), lineWidth: 1))
                        .opacity(currentStep > 0 ? 1 : 0)
                }
                .buttonStyle(OnboardingButtonStyle())
                .disabled(currentStep == 0)
                .accessibilityLabel("Back")
                
                Spacer()
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.printPortalAccent : Color(UIColor.tertiaryLabel).opacity(0.5))
                            .frame(width: index == currentStep ? 24 : 8, height: 8)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: currentStep)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Step \(currentStep + 1) of \(steps.count)")
                
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
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Color.printPortalAccent))
                        .shadow(color: Color.printPortalAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(OnboardingButtonStyle())
                .accessibilityLabel(currentStep == steps.count - 1 ? "Get started" : "Next")
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

// Subtle press feedback for the round navigation buttons (actions unchanged)
private struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
