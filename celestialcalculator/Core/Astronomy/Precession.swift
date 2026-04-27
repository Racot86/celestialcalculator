import Foundation

/// IAU 1976 precession (Meeus 21). Inputs and outputs in radians.
enum Precession {
    static func precessJ2000ToDate(raRad alpha0: Double, decRad delta0: Double, jde: Double) -> (Double, Double) {
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        // Coefficients in arcseconds
        let zeta = AngleMath.degToRad((2306.2181 * t + 0.30188 * t*t + 0.017998 * t*t*t) / 3600.0)
        let z    = AngleMath.degToRad((2306.2181 * t + 1.09468 * t*t + 0.018203 * t*t*t) / 3600.0)
        let theta = AngleMath.degToRad((2004.3109 * t - 0.42665 * t*t - 0.041833 * t*t*t) / 3600.0)

        let A = cos(delta0) * sin(alpha0 + zeta)
        let B = cos(theta) * cos(delta0) * cos(alpha0 + zeta) - sin(theta) * sin(delta0)
        let C = sin(theta) * cos(delta0) * cos(alpha0 + zeta) + cos(theta) * sin(delta0)

        var alpha = atan2(A, B) + z
        alpha = AngleMath.normalizeRadians(alpha)
        let delta = asin(max(-1.0, min(1.0, C)))
        return (alpha, delta)
    }
}
