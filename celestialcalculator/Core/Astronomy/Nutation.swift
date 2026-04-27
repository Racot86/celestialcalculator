import Foundation

/// Truncated IAU 1980 nutation series — leading terms only (Meeus 22).
/// Accuracy ~1″ for navigation purposes; sufficient given our other approximations.
enum Nutation {
    /// (Δψ, Δε) in radians.
    static func nutation(jde: Double) -> (deltaPsi: Double, deltaEpsilon: Double) {
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        let d2r = Double.pi / 180.0

        // Mean elongation of Moon from Sun
        let D  = (297.85036 + 445267.111480 * t - 0.0019142 * t * t + t*t*t/189474.0) * d2r
        // Mean anomaly of Sun
        let M  = (357.52772 + 35999.050340 * t - 0.0001603 * t * t - t*t*t/300000.0) * d2r
        // Mean anomaly of Moon
        let Mp = (134.96298 + 477198.867398 * t + 0.0086972 * t * t + t*t*t/56250.0) * d2r
        // Moon's argument of latitude
        let F  = (93.27191 + 483202.017538 * t - 0.0036825 * t * t + t*t*t/327270.0) * d2r
        // Longitude of ascending node of Moon
        let Om = (125.04452 - 1934.136261 * t + 0.0020708 * t * t + t*t*t/450000.0) * d2r

        // Subset of leading terms: (D, M, M', F, Ω, ψ_sin_coef [0.0001"], ψ_t_coef, ε_cos_coef, ε_t_coef)
        let terms: [(Double,Double,Double,Double,Double,Double,Double,Double,Double)] = [
            (0,0,0,0,1, -171996, -174.2,  92025,  8.9),
            (-2,0,0,2,2, -13187,   -1.6,   5736, -3.1),
            (0,0,0,2,2,  -2274,   -0.2,    977, -0.5),
            (0,0,0,0,2,   2062,    0.2,   -895,  0.5),
            (0,1,0,0,0,   1426,   -3.4,     54, -0.1),
            (0,0,1,0,0,    712,    0.1,     -7,  0.0),
            (-2,1,0,2,2,  -517,    1.2,    224, -0.6),
            (0,0,0,2,1,   -386,   -0.4,    200,  0.0),
            (0,0,1,2,2,   -301,    0.0,    129, -0.1),
            (-2,-1,0,2,2,  217,   -0.5,    -95,  0.3),
            (-2,0,1,0,0,  -158,    0.0,      0,  0.0),
            (-2,0,0,2,1,  129,     0.1,    -70,  0.0),
            (0,0,-1,2,2,  123,     0.0,    -53,  0.0),
            (2,0,0,0,0,    63,     0.0,      0,  0.0),
            (0,0,1,0,1,    63,     0.1,    -33,  0.0),
            (2,0,-1,2,2,  -59,     0.0,     26,  0.0),
            (0,0,-1,0,1,  -58,    -0.1,     32,  0.0),
            (0,0,1,2,1,   -51,     0.0,     27,  0.0),
            (-2,0,2,0,0,   48,     0.0,      0,  0.0),
            (0,0,-2,2,1,   46,     0.0,    -24,  0.0),
            (2,0,0,2,2,   -38,     0.0,     16,  0.0),
            (0,0,2,2,2,   -31,     0.0,     13,  0.0),
            (0,0,2,0,0,    29,     0.0,      0,  0.0),
            (-2,0,1,2,2,   29,     0.0,    -12,  0.0),
            (0,0,0,2,0,    26,     0.0,      0,  0.0),
            (-2,0,0,2,0,  -22,     0.0,      0,  0.0),
            (0,0,-1,2,1,   21,     0.0,    -10,  0.0),
            (0,2,0,0,0,    17,    -0.1,      0,  0.0),
            (2,0,-1,0,1,   16,     0.0,     -8,  0.0),
            (-2,2,0,2,2,  -16,     0.1,      7,  0.0),
            (0,1,0,0,1,   -15,     0.0,      9,  0.0),
            (-2,0,1,0,1,  -13,     0.0,      7,  0.0),
            (0,-1,0,0,1,  -12,     0.0,      6,  0.0),
            (0,0,2,-2,0,   11,     0.0,      0,  0.0),
            (2,0,-1,2,1,  -10,     0.0,      5,  0.0),
            (2,0,1,2,2,    -8,     0.0,      3,  0.0),
            (0,1,0,2,2,     7,     0.0,     -3,  0.0),
            (-2,1,1,0,0,   -7,     0.0,      0,  0.0),
            (0,-1,0,2,2,   -7,     0.0,      3,  0.0),
            (2,0,0,2,1,    -7,     0.0,      3,  0.0),
            (2,0,1,0,0,     6,     0.0,      0,  0.0),
            (-2,0,2,2,2,    6,     0.0,     -3,  0.0),
            (-2,0,1,2,1,    6,     0.0,     -3,  0.0),
            (2,0,-2,0,1,   -6,     0.0,      3,  0.0),
            (2,0,0,0,1,    -6,     0.0,      3,  0.0),
            (0,-1,1,0,0,    5,     0.0,      0,  0.0),
            (-2,-1,0,2,1,  -5,     0.0,      3,  0.0),
            (-2,0,0,0,1,   -5,     0.0,      3,  0.0),
            (0,0,2,2,1,    -5,     0.0,      3,  0.0)
        ]

        var dpsi = 0.0, deps = 0.0
        for (cd,cm,cmp,cf,com,sp,spt,ce,cet) in terms {
            let arg = cd*D + cm*M + cmp*Mp + cf*F + com*Om
            dpsi += (sp + spt * t) * sin(arg)
            deps += (ce + cet * t) * cos(arg)
        }
        // Coefficients are in units of 0.0001 arcsecond
        let psiArcsec = dpsi * 0.0001
        let epsArcsec = deps * 0.0001
        return (
            AngleMath.degToRad(psiArcsec / 3600.0),
            AngleMath.degToRad(epsArcsec / 3600.0)
        )
    }

    static func nutationInLongitude(jde: Double) -> Double { nutation(jde: jde).deltaPsi }
    static func nutationInObliquity(jde: Double) -> Double { nutation(jde: jde).deltaEpsilon }
}
