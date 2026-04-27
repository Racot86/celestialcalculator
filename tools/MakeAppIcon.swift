// Renders the 1024x1024 app icon for celestialcalculator.
//
// The icon is a celestial-navigation emblem:
//   • charcoal field — the night sky / brutalist canvas
//   • a true-north 4-point compass star in hot orange — the body whose
//     true bearing the app reports
//   • a single horizon line in bone — the navigator's reference
//   • a small Polaris dot above and right of the star — the universal
//     reference for celestial north
//   • thin corner registration marks — echoing the in-app brutalist UI
//
// Run:  swift tools/MakeAppIcon.swift  <out_path>

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import AppKit

let outPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "celestialcalculator/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

let size = 1024
let s = CGFloat(size)

let charcoal = CGColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1)
let charcoal2 = CGColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1)
let bone     = CGColor(red: 0.93, green: 0.90, blue: 0.85, alpha: 1)
let orange   = CGColor(red: 0.95, green: 0.36, blue: 0.13, alpha: 1)
let orangeDeep = CGColor(red: 0.78, green: 0.22, blue: 0.10, alpha: 1)

let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: size, height: size,
                          bitsPerComponent: 8, bytesPerRow: 0,
                          space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fputs("could not create context\n", stderr); exit(1)
}

// 1. Background gradient (top brighter, bottom darker)
let gradient = CGGradient(colorsSpace: cs,
                          colors: [charcoal2, charcoal] as CFArray,
                          locations: [0, 1])!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: s),
                       end: CGPoint(x: 0, y: 0),
                       options: [])

// 2. Faint horizon stripe in lower third
ctx.setStrokeColor(bone)
ctx.setLineWidth(2)
ctx.setAlpha(0.35)
ctx.move(to: CGPoint(x: 110, y: s * 0.34))
ctx.addLine(to: CGPoint(x: s - 110, y: s * 0.34))
ctx.strokePath()
ctx.setAlpha(1)

// 3. Thin altitude tick marks along the horizon
ctx.setStrokeColor(bone)
ctx.setAlpha(0.55)
ctx.setLineWidth(2)
for i in 0...8 {
    let x = 110 + CGFloat(i) * (s - 220) / 8
    ctx.move(to: CGPoint(x: x, y: s * 0.34))
    ctx.addLine(to: CGPoint(x: x, y: s * 0.34 - 16))
    ctx.strokePath()
}
ctx.setAlpha(1)

// 4. Compass star — 4-point geometric figure (kite-shape star)
let center = CGPoint(x: s / 2, y: s * 0.58)
let armLong: CGFloat = 360
let armShort: CGFloat = 110

// outer "halo" diamond in deep orange
ctx.setFillColor(orangeDeep)
let halo = CGMutablePath()
halo.move(to: CGPoint(x: center.x, y: center.y + armLong + 30))
halo.addLine(to: CGPoint(x: center.x + armShort + 30, y: center.y))
halo.addLine(to: CGPoint(x: center.x, y: center.y - armLong - 30))
halo.addLine(to: CGPoint(x: center.x - armShort - 30, y: center.y))
halo.closeSubpath()
ctx.addPath(halo)
ctx.fillPath()

// inner star in hot orange
ctx.setFillColor(orange)
let star = CGMutablePath()
// vertical (long) axis
star.move(to: CGPoint(x: center.x, y: center.y + armLong))
star.addLine(to: CGPoint(x: center.x + armShort, y: center.y))
star.addLine(to: CGPoint(x: center.x, y: center.y - armLong))
star.addLine(to: CGPoint(x: center.x - armShort, y: center.y))
star.closeSubpath()
ctx.addPath(star)
ctx.fillPath()

// horizontal (short) cross in slightly lighter shade for depth
ctx.setFillColor(CGColor(red: 1.0, green: 0.55, blue: 0.25, alpha: 1))
let cross = CGMutablePath()
cross.move(to: CGPoint(x: center.x + armLong, y: center.y))
cross.addLine(to: CGPoint(x: center.x, y: center.y + armShort))
cross.addLine(to: CGPoint(x: center.x - armLong, y: center.y))
cross.addLine(to: CGPoint(x: center.x, y: center.y - armShort))
cross.closeSubpath()
ctx.addPath(cross)
ctx.fillPath()

// 5. Polaris-style small reference dot
ctx.setFillColor(bone)
let polaris = CGRect(x: s * 0.78, y: s * 0.82, width: 22, height: 22)
ctx.fillEllipse(in: polaris)
// halo around polaris
ctx.setStrokeColor(bone)
ctx.setAlpha(0.4)
ctx.setLineWidth(2)
ctx.strokeEllipse(in: polaris.insetBy(dx: -10, dy: -10))
ctx.setAlpha(1)

// 6. Corner registration marks (brutalist)
ctx.setStrokeColor(bone)
ctx.setLineWidth(6)
let inset: CGFloat = 70
let arm: CGFloat = 80
// top-left
ctx.move(to: CGPoint(x: inset, y: s - inset)); ctx.addLine(to: CGPoint(x: inset + arm, y: s - inset)); ctx.strokePath()
ctx.move(to: CGPoint(x: inset, y: s - inset)); ctx.addLine(to: CGPoint(x: inset, y: s - inset - arm)); ctx.strokePath()
// top-right
ctx.move(to: CGPoint(x: s - inset, y: s - inset)); ctx.addLine(to: CGPoint(x: s - inset - arm, y: s - inset)); ctx.strokePath()
ctx.move(to: CGPoint(x: s - inset, y: s - inset)); ctx.addLine(to: CGPoint(x: s - inset, y: s - inset - arm)); ctx.strokePath()
// bottom-left
ctx.move(to: CGPoint(x: inset, y: inset)); ctx.addLine(to: CGPoint(x: inset + arm, y: inset)); ctx.strokePath()
ctx.move(to: CGPoint(x: inset, y: inset)); ctx.addLine(to: CGPoint(x: inset, y: inset + arm)); ctx.strokePath()
// bottom-right
ctx.move(to: CGPoint(x: s - inset, y: inset)); ctx.addLine(to: CGPoint(x: s - inset - arm, y: inset)); ctx.strokePath()
ctx.move(to: CGPoint(x: s - inset, y: inset)); ctx.addLine(to: CGPoint(x: s - inset, y: inset + arm)); ctx.strokePath()

// 7. Tiny "Zn" wordmark, lower-left, monospaced bone — meaning: "true azimuth"
let attrs: [NSAttributedString.Key: Any] = [
    .foregroundColor: NSColor(cgColor: bone) ?? NSColor.white,
    .font: NSFont.monospacedSystemFont(ofSize: 56, weight: .heavy),
    .kern: NSNumber(value: 1.5)
]
let zn = NSAttributedString(string: "Zn", attributes: attrs)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
zn.draw(at: NSPoint(x: 170, y: 170))
NSGraphicsContext.restoreGraphicsState()

// Save PNG
guard let image = ctx.makeImage() else { fputs("no image\n", stderr); exit(1) }
let url = URL(fileURLWithPath: outPath)
try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
guard let dst = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fputs("no destination\n", stderr); exit(1)
}
CGImageDestinationAddImage(dst, image, nil)
if !CGImageDestinationFinalize(dst) {
    fputs("finalize failed\n", stderr); exit(1)
}
print("Wrote \(outPath)")
