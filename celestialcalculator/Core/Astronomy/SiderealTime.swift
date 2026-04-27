import Foundation

enum SiderealTime {
    /// Greenwich Mean Sidereal Time in radians (Meeus 12.4).
    static func gmst(jdUT: Double) -> Double {
        let t = JulianDate.centuriesSinceJ2000(jd: jdUT)
        var theta = 280.46061837
            + 360.98564736629 * (jdUT - JulianDate.j2000)
            + 0.000387933 * t * t
            - t * t * t / 38710000.0
        theta = AngleMath.normalizeDegrees(theta)
        return AngleMath.degToRad(theta)
    }

    /// Greenwich Apparent Sidereal Time (radians) — GMST + equation of equinoxes.
    static func gast(jdUT: Double) -> Double {
        let jde = JulianDate.jde(from: jdUT)
        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let eps = Obliquity.trueObliquity(jde: jde)
        return gmst(jdUT: jdUT) + dpsi * cos(eps)
    }

    /// Local Apparent Sidereal Time (radians). longitudeEastRad: east-positive.
    static func last(jdUT: Double, longitudeEastRad: Double) -> Double {
        AngleMath.normalizeRadians(gast(jdUT: jdUT) + longitudeEastRad)
    }
}
