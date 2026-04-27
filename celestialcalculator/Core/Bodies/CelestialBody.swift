import Foundation

protocol CelestialBody {
    /// Apparent geocentric (or topocentric, for Moon) equatorial coordinates of date.
    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates
}

extension CelestialBody {
    func horizontalCoordinates(for observer: Observer) -> HorizontalCoordinates {
        let jdUT = JulianDate.julianDay(from: observer.date)
        let eq = apparentEquatorial(jdUT: jdUT)
        let phi = AngleMath.degToRad(observer.latitude)
        let lonRad = AngleMath.degToRad(observer.longitude)
        let lst = SiderealTime.last(jdUT: jdUT, longitudeEastRad: lonRad)
        return HorizontalTransform.horizontal(from: eq,
                                              latitudeRad: phi,
                                              localApparentSiderealTimeRad: lst)
    }
}

enum BodyFactory {
    static func body(for id: CelestialBodyID) -> CelestialBody {
        switch id {
        case .sun: return Sun()
        case .moon: return Moon()
        case .planet(let p): return Planet(kind: p)
        case .star(let i): return Star(catalogIndex: i)
        }
    }
}
