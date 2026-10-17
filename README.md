# PrintPortal: AR Signage Visualization

PrintPortal is an iOS augmented reality application designed to help users visualize physical print products—such as A-Frames, Roll-up Banners, and Rigid Boards—in their actual environment before purchasing. Built with SwiftUI, ARKit, RealityKit, and SwiftData, the app allows users to dynamically scale 3D models, apply custom artwork textures in real-time, and seamlessly generate order quotes.

## How to Build and Run the App

### Prerequisites
*   **Mac** running macOS Sonoma (or later).
*   **Xcode 15** (or later) installed.
*   **Physical iOS Device:** This app requires ARKit, RealityKit, and camera access. **It will not function correctly on an Xcode Simulator.** Please test on a physical iPhone or iPad (LiDAR-equipped devices recommended for fastest plane detection).

### Installation Steps
1. **Clone the Repository:** 
   Download the ZIP or clone the repo using terminal:
   `git clone https://github.com/YourUsername/IT23168268-SE4041-Assignment-2-Part-A.git`
2. **Open the Project:** 
   Navigate into the downloaded folder and open `PrintPortal.xcodeproj` (or `.xcworkspace` if applicable).
3. **Configure Signing:** 
   Click on the `PrintPortal` target in the left navigator. Go to the **Signing & Capabilities** tab and select your Apple Developer Team.
4. **Build and Run:** 
   Connect your physical iOS device via USB. Select your device from the destination menu at the top of Xcode, and press the **Play** button (`Cmd + R`) to build and run the app.
   
---

## Interface Showcase

<div align="center">
  <img width="45%" alt="image_123650291" src="https://github.com/user-attachments/assets/6c6c49a0-4ddf-4d1d-a89a-a977578f34ba" />
  <img width="45%" alt="image_123655411 (1)" src="https://github.com/user-attachments/assets/de408660-d276-4d14-842d-f89dca6abf6e" />
  <br>
  <em>The main product browsing interface, fully responsive to iOS system appearance.</em>
</div>
<br>

<div align="center">
  <img width="45%" alt="image_123655411" src="https://github.com/user-attachments/assets/80373f40-8e7e-42c1-bb74-3aa6a49ba18e" />
  <br>
  <em>Configuring the product dimensions and uploading custom 2D artwork.</em>
</div>
<br>

<div align="center">
  <img width="45%" alt="ar view 2" src="https://github.com/user-attachments/assets/f59076b1-bb5d-4da9-818a-5dd03beba032" />
  <br>
  <em>Real-time visualization of the 3D model placed in a physical space using ARKit.</em>
</div>
<br>

<div align="center">
  <img width="45%" alt="account" src="https://github.com/user-attachments/assets/d6c063cb-5a6e-4a12-9366-90f5775a29c4" />
  <img width="45%" alt="quote" src="https://github.com/user-attachments/assets/9afc76e6-54a3-43cc-9c1f-908c7185d187" />
  <br>
  <em>Seamless authentication and autofilled quote generation.</em>
</div>
<br>

<div align="center">
  <img width="45%" alt="email" src="https://github.com/user-attachments/assets/a53c08d2-b997-4e8c-bbcd-3ba756ad2223" />
  <br>
  <em>The final pre-formatted order request ready to be sent to the print shop.</em>
</div>
<br>

---

### Cross-Device Responsiveness
The application was engineered to provide a consistent, intuitive experience across all Apple devices and orientations:
- **Fluid Grids:** The Catalogue utilizes SwiftUI's `LazyVGrid` with flexible columns. On a narrow iPhone in portrait mode, it displays a neat 2-column layout. On larger devices like an iPad or in landscape orientation, the grid dynamically expands to utilize the extra screen real estate without stretching the product cards.
- **Adaptive Layouts:** Core screens like the Design Studio and Request a Quote form are wrapped in `ScrollView` containers. This ensures that smaller devices (like the iPhone SE) or horizontal orientations never suffer from clipped content or inaccessible buttons.
- **Safe Area Handling:** All custom UI elements, such as the floating AR camera controls and bottom tab bars, respect iOS safe area insets, preventing overlap with the dynamic island, notch, or home indicator across different device models.

<div align="center">
  <img width="28%" alt="iphone air" src="https://github.com/user-attachments/assets/d420f5d4-aa78-47e2-a80b-b30223153b61" />
  <img width="65%" alt="ipad air" src="https://github.com/user-attachments/assets/4cd70ee5-f482-41ef-ad08-2358ac066cd7" />
  <br>
  <em>The UI dynamically adapts to different screen sizes and orientations, utilizing fluid grids and safe-area insets.</em>
</div>
<br>

## 1. User Guide

PrintPortal is designed to be intuitive and strictly follows Apple's Human Interface Guidelines for a seamless iOS experience.

### How to Use the App:
1. **Browse the Catalogue:** Launch the app to view the featured products. Use the search bar to filter items or tap the heart icon to save a product to your Favorites.
2. **Configure Your Sign:** Tap a product to enter the Design Studio. Here, you can define custom dimensions (width/height) and upload your own 2D artwork.
3. **Scan the Room & Place:** Enter the AR view and move your iPhone side-to-side to detect the floor. Tap to place the sign, and use standard iOS gestures (one-finger drag, two-finger twist) to position it perfectly.
4. **Take a Snapshot:** Tap the camera button to capture an AR photo of the sign in your space, which saves directly to your iOS Photos app for future reference.
5. **Request a Quote & Checkout:** Once satisfied with your design, tap 'Send Quote'. 
    * If you haven't created an account, the app will prompt you to sign up. 
    * Once authenticated, the 'Request a Quote' form will automatically autofill with your personal details and attach your configured sign image. 
    * Submitting the form instantly generates a pre-formatted email draft containing all your project specs, ready for you to send directly to the print shop!

---

## 2. Technical Documentation

### Architecture & Tech Stack
*   **UI Framework:** SwiftUI (MVVM architecture, fully supporting Dark Mode and Dynamic Type).
*   **Augmented Reality:** ARKit (World Tracking, Plane Detection) and RealityKit (Rendering, Gestures, Custom Materials).
*   **Local Persistence & State:** SwiftData (managing Favorite Products and saved Projects) alongside `@AppStorage` and Environment Objects for user authentication state.
*   **3D Assets:** Custom modeled in Autodesk Maya and Blender, exported to `.usdz` format for native iOS compatibility.

### Core Mechanisms
*   **Dynamic Scaling:** 3D models are built to real-world scale (e.g., a standard Roll-up Banner is 84x206cm). The app uses a scaling multiplier applied directly to the RealityKit `ModelEntity` to dynamically resize the mesh without distorting the frame.
*   **Real-time Texture Mapping:** The app locates the specific material layer inside the USDZ file and safely replaces it with a `SimpleMaterial` generated from the user's uploaded `UIImage`.
*   **Automated Quote Generation:** User profile data and the final generated composite image are seamlessly passed through local state into the standard iOS Mail interface, automating the quoting process without requiring a backend server.

---

## 3. In-Depth Report

### 3.1 Design Decisions
*   **UI/UX Native Feel & Dark Mode Support:** Instead of imposing a heavily customized, non-standard interface, the app leans heavily into Apple's Human Interface Guidelines. Reusable components utilize `16pt` continuous corner radii, `.ultraThinMaterial` backgrounds, and semantic system colors to ensure the app looks premium and adapts flawlessly to Dark Mode.
*   **Frictionless Checkout Flow:** The decision to integrate account creation *at the point of friction* (when the user actually wants to send a quote) rather than blocking the app at launch prevents user drop-off. Autofilling the quote form and instantly generating an email draft creates a highly satisfying, zero-effort checkout experience.
*   **Pivot from ARWorldMap to Snapshots (MVP Scope):** Initially, the architecture included persistent AR room-saving via `ARWorldMap`. However, during development, it became clear that forcing the user to return to exact physical coordinates to view their sign was a cumbersome UX constraint. The design was pivoted to a streamlined "Snapshot" workflow, prioritizing quick photo generation over rigid world-saving.

### 3.2 Development Challenges & Solutions
1. **The 90-Degree Axis Flip (Maya to ARKit):** 
   * *Challenge:* When applying rotations to the AR Anchor, the 3D models would occasionally spawn tipped 90 degrees face-down on the floor. This was caused by the coordinate system mismatch between Maya (Z-up) and RealityKit (Y-up).
   * *Solution:* Refactored the anchor syncing logic to completely ignore absolute world vectors. Instead, the app extracts *only* the user's localized delta translation and rotation, multiplies it against the anchor, and cleanly reparents the entity while preserving its custom scale.
2. **Memory Spikes from High-Res Artwork:** 
   * *Challenge:* Users uploading massive 4K images for their sign textures caused RealityKit to spike RAM usage, occasionally lagging the camera.
   * *Solution:* Implemented a custom `UIImage` extension (`normalizedForRealityKit`) that mathematically shrinks the image to a maximum dimension of `1024px` while preserving its aspect ratio before feeding it to the 3D renderer.

### 3.3 Testing Results
Testing was integrated throughout the development lifecycle to ensure stability.

**Unit Testing:**
*   `testImageNormalization()`: Verified that the memory optimization logic correctly resizes massive mock images (2000x2000) down to the safe 1024x1024 RealityKit threshold without returning nil.

**UI & Integration Testing:**
*   `testCatalogueScreenLoadsCorrectly()`: Asserted the rendering of key SwiftUI view components and validated screen architecture.
*   `testFullUserJourneyNavigation()`: An automated End-to-End (E2E) test that verified the `NavigationStack` routing. The test simulated a user launching the app, tapping a product, verifying the back button on the details screen, and utilizing the Tab Bar.

<div align="center">
  <img width="45%" alt="ui testing 2" src="https://github.com/user-attachments/assets/cca67abd-4400-4fc7-9c9f-534642d24124" />
  <img width="45%" alt="Unit Testing" src="https://github.com/user-attachments/assets/272e3135-cc57-4166-90fe-65b035b86ccc" />
</div>

### 3.4 Reflections on the Development Process
Building PrintPortal was a profound exercise in balancing complex spatial mathematics with front-end usability. The most significant learning outcome was the realization that "less is often more" in product design. 

The decision to scrap the highly complex `ARWorldMap` feature in favor of a simple, robust camera snapshot feature fundamentally saved the project's timeline and improved the UX. Developing the automated quote feature further reinforced how powerful it is to leverage native iOS capabilities (like the Mail sheet) to deliver complex functionality seamlessly. Finally, relying on automated UI and Unit tests toward the end of the project provided the confidence needed to perform visual UI polishes across Light and Dark mode without the fear of breaking core logic.
