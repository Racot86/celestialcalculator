import Foundation

/// IAU 2006 precession (Capitaine, Wallace, Chapront 2003). Ecliptic-rotation
/// formulation using ζ_A, z_A, θ_A in arcseconds (T = TDB centuries from J2000).
/// Replaces IAU 1976. Inputs and outputs in radians.
enum Precession {
    static func precessJ2000ToDate(raRad alpha0: Double, decRad delta0: Double, jde: Double) -> (Double, Double) {
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        // Coefficients in arcseconds (Capitaine et al. 2003, IAU 2006)
        let zetaArc =     2.650545
                      + 2306.083227 * t
                      +    0.2988499 * t*t
                      +    0.01801828 * t*t*t
                      -    5.971e-6   * t*t*t*t
                      -    3.173e-7   * t*t*t*t*t
        let zArc    =    -2.650545
                      + 2306.077181 * t
                      +    1.0927348 * t*t
                      +    0.01826837 * t*t*t
                      -   28.596e-6   * t*t*t*t
                      -    2.904e-7   * t*t*t*t*t
        let thetaArc = 2004.191903 * t
                      -    0.4294934 * t*t
                      -    0.04182264 * t*t*t
                      -    7.089e-6   * t*t*t*t
                      -    1.274e-7   * t*t*t*t*t

        let zeta = AngleMath.degToRad(zetaArc / 3600.0)
        let z    = AngleMath.degToRad(zArc / 3600.0)
        let theta = AngleMath.degToRad(thetaArc / 3600.0)

        let A = cos(delta0) * sin(alpha0 + zeta)
        let B = cos(theta) * cos(delta0) * cos(alpha0 + zeta) - sin(theta) * sin(delta0)
        let C = sin(theta) * cos(delta0) * cos(alpha0 + zeta) + cos(theta) * sin(delta0)

        var alpha = atan2(A, B) + z
        alpha = AngleMath.normalizeRadians(alpha)
        let delta = asin(max(-1.0, min(1.0, C)))
        return (alpha, delta)
    }
}
