import AppKit
import Foundation

struct PreviewLocale {
    let code: String
    let title: String
    let subtitle: String
    let screenshotPath: String
    let outputPath: String
}

let fileManager = FileManager.default
let repoRoot = fileManager.currentDirectoryPath

let canvasSize = NSSize(width: 1280, height: 720)
let appIconPath = (repoRoot as NSString).appendingPathComponent("assets/app-icon-fallback.png")

let locales = [
    PreviewLocale(
        code: "de",
        title: "H\u{00F6}rB\u{00E4}r",
        subtitle: "H\u{00F6}rspiel-App f\u{00FC}r Kinder",
        screenshotPath: "assets/hero.png",
        outputPath: "assets/social/og-preview-de.png"
    ),
    PreviewLocale(
        code: "en",
        title: "H\u{00F6}rB\u{00E4}r",
        subtitle: "Audio Drama App for Kids",
        screenshotPath: "assets/hero.png",
        outputPath: "assets/social/og-preview-en.png"
    )
]

enum PreviewError: Error {
    case missingImage(String)
    case unableToEncode(String)
}

func drawRoundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func drawGlow(_ rect: NSRect, color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: rect).fill()
}

func drawImage(
    _ image: NSImage,
    in rect: NSRect,
    cornerRadius: CGFloat,
    background: NSColor? = nil,
    aspectFill: Bool
) {
    NSGraphicsContext.saveGraphicsState()
    let clipPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    clipPath.addClip()

    if let background {
        background.setFill()
        clipPath.fill()
    }

    let imageSize = image.size
    let widthRatio = rect.width / imageSize.width
    let heightRatio = rect.height / imageSize.height
    let scale = aspectFill ? max(widthRatio, heightRatio) : min(widthRatio, heightRatio)
    let scaledSize = NSSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let drawRect = NSRect(
        x: rect.midX - (scaledSize.width / 2),
        y: rect.midY - (scaledSize.height / 2),
        width: scaledSize.width,
        height: scaledSize.height
    )

    image.draw(in: drawRect)
    NSGraphicsContext.restoreGraphicsState()
}

func drawText(_ text: String, at point: NSPoint, font: NSFont, color: NSColor) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]

    NSString(string: text).draw(at: point, withAttributes: attributes)
}

func renderPreview(for locale: PreviewLocale) throws {
    guard let icon = NSImage(contentsOfFile: appIconPath) else {
        throw PreviewError.missingImage(appIconPath)
    }

    let screenshotAbsolutePath = (repoRoot as NSString).appendingPathComponent(locale.screenshotPath)
    guard let screenshot = NSImage(contentsOfFile: screenshotAbsolutePath) else {
        throw PreviewError.missingImage(screenshotAbsolutePath)
    }

    let outputAbsolutePath = (repoRoot as NSString).appendingPathComponent(locale.outputPath)
    let outputDirectory = (outputAbsolutePath as NSString).deletingLastPathComponent
    try fileManager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true)

    guard
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(canvasSize.width),
            pixelsHigh: Int(canvasSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
    else {
        throw PreviewError.unableToEncode(outputAbsolutePath)
    }

    let context = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let backgroundRect = NSRect(origin: .zero, size: canvasSize)
    drawRoundedRect(backgroundRect, radius: 0, color: NSColor(calibratedRed: 16 / 255, green: 30 / 255, blue: 49 / 255, alpha: 1))

    if let gradient = NSGradient(
        colors: [
            NSColor(calibratedRed: 30 / 255, green: 47 / 255, blue: 74 / 255, alpha: 1),
            NSColor(calibratedRed: 16 / 255, green: 30 / 255, blue: 49 / 255, alpha: 1)
        ]
    ) {
        gradient.draw(in: backgroundRect, angle: 0)
    }

    drawGlow(
        NSRect(x: -140, y: 420, width: 520, height: 320),
        color: NSColor(calibratedRed: 213 / 255, green: 117 / 255, blue: 28 / 255, alpha: 0.20)
    )
    drawGlow(
        NSRect(x: 220, y: -40, width: 420, height: 260),
        color: NSColor(calibratedRed: 96 / 255, green: 164 / 255, blue: 214 / 255, alpha: 0.12)
    )
    drawGlow(
        NSRect(x: 860, y: 180, width: 340, height: 340),
        color: NSColor(calibratedRed: 213 / 255, green: 117 / 255, blue: 28 / 255, alpha: 0.08)
    )

    let iconShadow = NSShadow()
    iconShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    iconShadow.shadowBlurRadius = 28
    iconShadow.shadowOffset = NSSize(width: 0, height: -8)
    NSGraphicsContext.saveGraphicsState()
    iconShadow.set()
    drawImage(icon, in: NSRect(x: 88, y: 452, width: 180, height: 180), cornerRadius: 40, background: nil, aspectFill: true)
    NSGraphicsContext.restoreGraphicsState()

    drawText(
        locale.title,
        at: NSPoint(x: 88, y: 204),
        font: NSFont.systemFont(ofSize: 82, weight: .bold),
        color: NSColor(calibratedWhite: 0.98, alpha: 1)
    )
    drawText(
        locale.subtitle,
        at: NSPoint(x: 88, y: 132),
        font: NSFont.systemFont(ofSize: 34, weight: .semibold),
        color: NSColor(calibratedWhite: 0.80, alpha: 1)
    )

    let artworkRect = NSRect(x: 700, y: 24, width: 520, height: 672)
    let artworkShadow = NSShadow()
    artworkShadow.shadowColor = NSColor.black.withAlphaComponent(0.30)
    artworkShadow.shadowBlurRadius = 48
    artworkShadow.shadowOffset = NSSize(width: 0, height: -14)
    NSGraphicsContext.saveGraphicsState()
    artworkShadow.set()
    drawImage(
        screenshot,
        in: artworkRect,
        cornerRadius: 34,
        background: NSColor.clear,
        aspectFill: false
    )
    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw PreviewError.unableToEncode(outputAbsolutePath)
    }

    try pngData.write(to: URL(fileURLWithPath: outputAbsolutePath))
    print("Generated \(locale.code): \(locale.outputPath)")
}

do {
    for locale in locales {
        try renderPreview(for: locale)
    }
} catch {
    fputs("Failed to generate OG previews: \(error)\n", stderr)
    exit(1)
}
