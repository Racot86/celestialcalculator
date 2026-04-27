import Foundation

nonisolated enum Obliquity {
    /// Mean obliquity of the ecliptic in radians (Meeus 22.2 / IAU 1980).
    static func meanObliquity(jde: Double) -> Double {
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        let secs = 84381.448
            - 46.8150 * t
            - 0.00059 * t * t
            + 0.001813 * t * t * t
        return AngleMath.degToRad(secs / 3600.0)
    }

    static func trueObliquity(jde: Double) -> Double {
        meanObliquity(jde: jde) + Nutation.nutationInObliquity(jde: jde)
    }
}
