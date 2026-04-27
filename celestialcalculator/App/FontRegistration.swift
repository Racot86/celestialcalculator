import Foundation
import CoreText

/// Registers every bundled TTF with CoreText at process scope.
///
/// The synchronized file group copies our font files into the app bundle as
/// resources, but it does **not** add a `UIAppFonts` entry to `Info.plist` —
/// so iOS has no idea those resources are fonts. Without explicit registration
/// here, `Font.custom("Orbitron-Bold", size:)` silently falls back to the
/// system face. Calling `CTFontManagerRegisterFontsForURL` (CoreText, no UIKit)
/// at app launch makes the PostScript names resolvable everywhere in SwiftUI.
enum FontRegistration {
    static func registerAll() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "ttf",
                                          subdirectory: nil) else { return }
        for url in urls {
            var error: Unmanaged<CFError>?
            // .process scope = available to this process only, no system-wide
            // pollution. Returns false on duplicates; we ignore that silently.
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            error?.release()
        }
    }
}
