import Foundation

/// Low-precision Sun position (Meeus chapter 25). Accuracy ~0.01°.
struct Sun: CelestialBody {
    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)
        let t = JulianDate.centuriesSinceJ2000(jd: jde)

        let L0 = AngleMath.normalizeDegrees(280.46646 + 36000.76983 * t + 0.0003032 * t * t)
        let M = AngleMath.normalizeDegrees(357.52911 + 35999.05029 * t - 0.0001537 * t * t)
        let Mr = AngleMath.degToRad(M)
        let e = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t

        let C = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(Mr)
            + (0.019993 - 0.000101 * t) * sin(2 * Mr)
            + 0.000289 * sin(3 * Mr)

        let trueLong = L0 + C
        _ = e
        // Apparent longitude (Meeus 25.8)
        let omega = AngleMath.degToRad(125.04 - 1934.136 * t)
        let lambdaDeg = trueLong - 0.00569 - 0.00478 * sin(omega)
        let lambda = AngleMath.degToRad(lambdaDeg)

        // Use true obliquity already includes nutation in obliquity; for apparent RA/Dec
        // we use ε corrected: ε + 0.00256°·cos Ω is per Meeus shortcut.
        let epsMean = Obliquity.meanObliquity(jde: jde)
        let eps = epsMean + AngleMath.degToRad(0.00256 * cos(omega))

        let ra = atan2(cos(eps) * sin(lambda), cos(lambda))
        let dec = asin(sin(eps) * sin(lambda))
        return EquatorialCoordinates(
            rightAscension: ra < 0 ? ra + 2 * .pi : ra,
            declination: dec,
            distanceAU: nil
        )
    }
}
