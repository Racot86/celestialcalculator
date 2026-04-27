import Foundation
import CoreText
import UIKit

/// Registers + warms bundled fonts for SwiftUI lookups.
///
/// Two purposes:
///   1. Register the fonts in the process — only if Xcode's auto-registration
///      hasn't already done it (which it does for synchronized file groups in
///      modern Xcode), to avoid the "file already registered" log noise.
///   2. Pre-warm the glyph metric / rendering caches for every face we use
///      inside wheel pickers. Without this, the first time a Picker(.wheel)
///      mounts with a custom font it stalls for several frames while Core
///      Text computes glyph advances for the full digit range.
enum FontRegistration {
    static let warmupNames = [
        "Orbitron-Regular", "Orbitron-Medium", "Orbitron-SemiBold",
        "Orbitron-Bold", "Orbitron-ExtraBold", "Orbitron-Black",
        "Roboto-Regular", "Roboto-Medium", "Roboto-Bold",
        "ZenDots-Regular", "BitcountGridSingleInk-Regular"
    ]

    static func registerAll() {
        if UIFont(name: "Orbitron-Regular", size: 1) == nil {
            registerFromBundle()
        }
        warmGlyphs()
    }

    private static func registerFromBundle() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "ttf",
                                          subdirectory: nil) else { return }
        for url in urls {
            var error: Unmanaged<CFError>?
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }

    /// Force the renderer to compute glyph metrics for the digits + a few
    /// punctuation glyphs the wheels use. This is the slow part on first
    /// picker mount; doing it here moves it to launch-time once.
    private static func warmGlyphs() {
        let sample = "0123456789°.':NSEW-+ "
        for name in warmupNames {
            for size: CGFloat in [11, 12, 13, 15, 17, 20, 92] {
                guard let font = UIFont(name: name, size: size) else { continue }
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                _ = (sample as NSString).size(withAttributes: attrs)
            }
        }
    }
}
