import Foundation

/// Apparent geocentric position of the Sun derived from VSOP87D Earth heliocentric.
/// Geocentric Sun longitude = Earth heliocentric longitude + 180°.
/// Includes light-time aberration and nutation in longitude.
struct Sun: CelestialBody {
    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)

        // Light-time correction: Sun's light takes ~8 min 20 s to reach Earth.
        // Solve iteratively using current Earth–Sun distance.
        var earth = VSOP87Body.earth(jde: jde)
        let cAUperDay = 173.144632674
        let tau = earth.r / cAUperDay
        earth = VSOP87Body.earth(jde: jde - tau)

        // Geocentric Sun ecliptic = (lon + π, -lat)
        let lambdaGeocentric = earth.lon + .pi
        let betaGeocentric = -earth.lat

        // FK5 frame correction (Meeus 25): -0.09033″ to longitude
        let lambdaFK5 = lambdaGeocentric - AngleMath.degToRad(0.09033 / 3600.0)

        // Apparent longitude: + nutation in longitude
        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let lambdaApp = lambdaFK5 + dpsi
        let eps = Obliquity.trueObliquity(jde: jde)
        var eq = EclipticToEquatorial.convert(longitudeRad: lambdaApp,
                                              latitudeRad: betaGeocentric,
                                              obliquityRad: eps)
        eq.distanceAU = earth.r
        return eq
    }
}
