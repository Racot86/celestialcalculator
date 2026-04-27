import SwiftUI

/// Adaptive colors from Assets.xcassets.
enum BrutalistTheme {
    static let background = Color("BrutalistBackground")
    static let foreground = Color("BrutalistForeground")
    static let muted      = Color("BrutalistMuted")
    static let accent     = Color("BrutalistAccent")
    static let signal = Color(red: 0.85, green: 0.25, blue: 0.15)
}

/// Font roles. SF intentionally absent. Layered by purpose:
///
/// • Zen Dots Regular   — panel titles & "brutalist" headlines
/// • Orbitron family    — every numeric/value (hero numerals, table values)
/// • Roboto family      — important readable text: table column headers,
///                        body labels, captions a navigator actually reads
/// • Bitcount Grid      — decorative accents only (kanji-style chips,
///                        serial-number flair)
extension Font {
    // MARK: hero / panel-title (brutalist)
    static func brutalistLabel(_ size: CGFloat) -> Font {
        .custom("ZenDots-Regular", size: size)
    }

    // MARK: numeric/value (Orbitron — DO NOT change without consulting the user)
    static func brutalistDisplay(_ size: CGFloat) -> Font {
        .custom("Orbitron-Black", size: size)
    }
    static func brutalistMonoBold(_ size: CGFloat) -> Font {
        .custom("Orbitron-Bold", size: size)
    }
    static func brutalistMono(_ size: CGFloat) -> Font {
        .custom("Orbitron-Regular", size: size)
    }

    // MARK: readable text (Roboto)
    /// Body / table-cell label that the user actually reads.
    static func brutalistText(_ size: CGFloat) -> Font {
        .custom("Roboto-Regular", size: size)
    }
    /// Table column header / important caption — emphasis weight.
    static func brutalistTextBold(_ size: CGFloat) -> Font {
        .custom("Roboto-Bold", size: size)
    }
    static func brutalistTextMedium(_ size: CGFloat) -> Font {
        .custom("Roboto-Medium", size: size)
    }

    // MARK: decoration (Bitcount)
    /// Decorative-only — never carries meaning a navigator must read precisely.
    static func brutalistDecorative(_ size: CGFloat) -> Font {
        .custom("BitcountGridSingleInk-Regular", size: size)
    }
}
