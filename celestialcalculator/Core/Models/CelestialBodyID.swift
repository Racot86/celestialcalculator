import Foundation

nonisolated enum CelestialBodyID: Hashable, Identifiable {
    case sun
    case moon
    case planet(PlanetKind)
    case star(Int)

    var id: String {
        switch self {
        case .sun: return "sun"
        case .moon: return "moon"
        case .planet(let p): return "planet.\(p.rawValue)"
        case .star(let i): return "star.\(i)"
        }
    }

    var displayName: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .planet(let p): return p.displayName
        case .star(let i): return NavigationalStars.all[i].name
        }
    }

    var classification: String {
        switch self {
        case .sun, .moon: return "LUMINARY"
        case .planet: return "PLANET"
        case .star: return "NAV STAR"
        }
    }

    /// Unicode astronomical symbol for the body.
    /// Sun ☉, Moon ☾, Mercury ☿, Venus ♀, Mars ♂, Jupiter ♃, Saturn ♄.
    /// Stars use their Bayer designation (e.g. "α Tau") since no per-star
    /// astronomical glyph exists.
    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☾"
        case .planet(let p):
            switch p {
            case .venus:   return "♀"
            case .mars:    return "♂"
            case .jupiter: return "♃"
            case .saturn:  return "♄"
            }
        case .star(let i): return NavigationalStars.all[i].bayer
        }
    }

    /// Long-form display "☉ Sun" / "♂ Mars" / "α Tau Aldebaran".
    var displayWithSymbol: String {
        switch self {
        case .star: return "\(symbol)  \(displayName)"
        default:    return "\(symbol)  \(displayName)"
        }
    }
}

nonisolated enum PlanetKind: String, CaseIterable {
    case venus, mars, jupiter, saturn

    var displayName: String { rawValue.capitalized }
}
