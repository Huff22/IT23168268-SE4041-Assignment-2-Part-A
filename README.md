# PrintPortal: AR Signage Visualization 🪧

PrintPortal is an iOS augmented reality application designed to help users visualize physical print products—such as A-Frames, Roll-up Banners, and Rigid Boards—in their actual environment before purchasing. Built with SwiftUI, ARKit, RealityKit, and SwiftData, the app allows users to dynamically scale 3D models, apply custom artwork textures in real-time, and seamlessly generate order quotes.

---

## 📱 Interface Showcase

> **[📸 INSERT: Catalogue View - Light Mode]** | **[📸 INSERT: Catalogue View - Dark Mode]**
> *The main product browsing interface, fully responsive to iOS system appearance.*

> **[📸 INSERT: Design Studio / Product Details View]**
> *Configuring the product dimensions and uploading custom 2D artwork.*

> **[📸 INSERT: AR View - Placing the Sign]**
> *Real-time visualization of the 3D model placed in a physical space using ARKit.*

> **[📸 INSERT: Account Creation Screen]** | **[📸 INSERT: Request a Quote Form]**
> *Seamless authentication and autofilled quote generation.*

> **[📸 INSERT: Generated Email Draft]**
> *The final pre-formatted order request ready to be sent to the print shop.*

---

## 📖 1. User Guide

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

## 🛠 2. Technical Documentation

### Architecture & Tech Stack
*   **UI Framework:** SwiftUI (MVVM architecture, fully supporting Dark Mode and Dynamic Type).
*   **Augmented Reality:** ARKit (World Tracking, Plane Detection) and RealityKit (Rendering, Gestures, Custom Materials).
*   **Local Persistence & State:** SwiftData (managing Favorite Products and saved Projects) alongside `@AppStorage` and Environment Objects for user authentication state.
*   **3D Assets:** Custom modeled in Autodesk Maya / Blender, exported to `.usdz` format for native iOS compatibility.

### Core Mechanisms
*   **Dynamic Scaling:** 3D models are built to real-world scale (e.g., a standard Roll-up Banner is 84x206cm). The app uses a scaling multiplier applied directly to the RealityKit `ModelEntity` to dynamically resize the mesh without distorting the frame.
*   **Real-time Texture Mapping:** The app locates the specific material layer inside the USDZ file and safely replaces it with a `SimpleMaterial` generated from the user's uploaded `UIImage`.
*   **Automated Quote Generation:** User profile data and the final generated composite image are seamlessly passed through local state into the standard iOS Mail interface, automating the quoting process without requiring a backend server.

---

## 📊 3. In-Depth Report

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

> **[📸 INSERT: A screenshot of Xcode showing the green checkmarks next to your UI and Unit tests passing]**
> **[📸 INSERT: A screenshot showing the 0 failures output from the Xcode debug console]**

### 3.4 Reflections on the Development Process
Building PrintPortal was a profound exercise in balancing complex spatial mathematics with front-end usability. The most significant learning outcome was the realization that "less is often more" in product design. 

The decision to scrap the highly complex `ARWorldMap` feature in favor of a simple, robust camera snapshot feature fundamentally saved the project's timeline and improved the UX. Developing the automated quote feature further reinforced how powerful it is to leverage native iOS capabilities (like the Mail sheet) to deliver complex functionality seamlessly. Finally, relying on automated UI and Unit tests toward the end of the project provided the confidence needed to perform visual UI polishes across Light and Dark mode without the fear of breaking core logic.
