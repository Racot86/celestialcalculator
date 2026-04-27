import SwiftUI

/// All colors are read from Assets.xcassets and adapt automatically to the
/// system color scheme (light → bone palette, dark → charcoal palette).
enum BrutalistTheme {
    static let background = Color("BrutalistBackground")
    static let foreground = Color("BrutalistForeground")
    static let muted      = Color("BrutalistMuted")
    static let accent     = Color("BrutalistAccent")

    /// Used for "below horizon" / warning indicators.
    static let signal = Color(red: 0.85, green: 0.25, blue: 0.15)
}

extension Font {
    static func brutalistDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    static func brutalistMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    static func brutalistMonoBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
    static func brutalistLabel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }
}
