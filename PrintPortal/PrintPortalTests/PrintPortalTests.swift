//
//  PrintPortalTests.swift
//  PrintPortalTests
//
//  Created by Hafsa Faleel on 2026-10-11.
//
import XCTest
@testable import PrintPortal

final class PrintPortalTests: XCTestCase {

    // Test to ensure our ARKit image optimizer works perfectly
    func testImageNormalization() throws {
        // 1. Create a massive fake image that is way too big for ARKit (2000x2000)
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2000, height: 2000), format: format)
        let massiveImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 2000, height: 2000))
        }
        
        // 2. Run our performance optimization function
        let optimizedImage = massiveImage.normalizedForRealityKit()
        
        // 3. Assert that the image was successfully shrunk to a maximum of 1024 to save memory
        XCTAssertNotNil(optimizedImage, "The optimizer should return a valid image.")
        XCTAssertLessThanOrEqual(optimizedImage!.size.width, 1024, "Image width was not optimized down to 1024.")
        XCTAssertLessThanOrEqual(optimizedImage!.size.height, 1024, "Image height was not optimized down to 1024.")
    }
}
