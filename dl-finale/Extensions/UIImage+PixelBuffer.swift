//
//  UIImage+PixelBuffer.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import UIKit
import CoreVideo

extension UIImage {
    /// Converts and resizes the image to a `CVPixelBuffer` suitable for CoreML input.
    /// - Parameter size: Target size. Defaults to 224×224 (MobileNetV2 input).
    /// - Returns: A locked, ready-to-use pixel buffer, or `nil` on failure.
    func toCVPixelBuffer(size: CGSize = CGSize(width: 224, height: 224)) -> CVPixelBuffer? {
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }

        // UIImage origin is top-left; CGContext origin is bottom-left — flip it.
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        UIGraphicsPushContext(context)
        draw(in: CGRect(origin: .zero, size: size))
        UIGraphicsPopContext()

        return buffer
    }
}
