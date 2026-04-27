import Foundation

/// Annual aberration of star coordinates (Meeus 23.2). Returns (Δα, Δδ) in radians.
enum Aberration {
    static func annualAberration(raRad ra: Double, decRad dec: Double, jde: Double) -> (Double, Double) {
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        let kappa = AngleMath.degToRad(20.49552 / 3600.0) // constant of aberration

        // Sun's true longitude (low precision)
        let L0 = AngleMath.normalizeDegrees(280.46646 + 36000.76983 * t)
        let M = AngleMath.degToRad(AngleMath.normalizeDegrees(357.52911 + 35999.05029 * t))
        let C = (1.914602 - 0.004817 * t) * sin(M)
            + (0.019993 - 0.000101 * t) * sin(2*M)
            + 0.000289 * sin(3*M)
        let trueSunLong = AngleMath.degToRad(L0 + C)
        let e = 0.016708634 - 0.000042037 * t
        let pi = AngleMath.degToRad(102.93768193 + 1.71946 * t / 100.0)
        let eps = Obliquity.meanObliquity(jde: jde)

        let cosA = cos(ra), sinA = sin(ra), cosD = cos(dec), sinD = sin(dec)
        let cosL = cos(trueSunLong), sinL = sin(trueSunLong)
        let cosP = cos(pi), sinP = sin(pi)
        let cosE = cos(eps)

        let dRA = -kappa * (cosA * cosL * cosE + sinA * sinL) / cosD
                  + e * kappa * (cosA * cosP * cosE + sinA * sinP) / cosD
        let dDec = -kappa * (cosL * cosE * (tan(eps) * cosD - sinA * sinD) + cosA * sinD * sinL)
                   + e * kappa * (cosP * cosE * (tan(eps) * cosD - sinA * sinD) + cosA * sinD * sinP)
        return (dRA, dDec)
    }
}
