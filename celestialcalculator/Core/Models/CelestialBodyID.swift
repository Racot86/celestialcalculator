import Foundation

enum CelestialBodyID: Hashable, Identifiable {
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
}

enum PlanetKind: String, CaseIterable {
    case venus, mars, jupiter, saturn

    var displayName: String { rawValue.capitalized }
}
