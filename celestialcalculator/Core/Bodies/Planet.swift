import Foundation

/// All four navigational planets via the full VSOP87D heliocentric series
/// (ecliptic-of-date, no precession bookkeeping needed).
nonisolated struct Planet: CelestialBody {
    let kind: PlanetKind

    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)

        let earthHelio = vsopSphericalToRect(VSOP87Body.earth(jde: jde))
        var planetHelio = vsopSphericalToRect(spherical(jde: jde))

        // Light-time iteration (~2 passes converges to << 1″)
        var dx = planetHelio.x - earthHelio.x
        var dy = planetHelio.y - earthHelio.y
        var dz = planetHelio.z - earthHelio.z
        var dist = sqrt(dx*dx + dy*dy + dz*dz)
        let cAUperDay = 173.144632674
        for _ in 0..<2 {
            let tau = dist / cAUperDay
            planetHelio = vsopSphericalToRect(spherical(jde: jde - tau))
            dx = planetHelio.x - earthHelio.x
            dy = planetHelio.y - earthHelio.y
            dz = planetHelio.z - earthHelio.z
            dist = sqrt(dx*dx + dy*dy + dz*dz)
        }

        let lambda0 = AngleMath.normalizeRadians(atan2(dy, dx))
        let beta0 = atan2(dz, sqrt(dx*dx + dy*dy))

        // Annual aberration of planetary apparent place.
        let (dLam, dBet) = Aberration.annualEclipticCorrection(
            longitudeRad: lambda0, latitudeRad: beta0, jde: jde)
        let lambda = lambda0 + dLam
        let beta = beta0 + dBet

        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let lambdaApp = lambda + dpsi
        let eps = Obliquity.trueObliquity(jde: jde)
        var eq = EclipticToEquatorial.convert(longitudeRad: lambdaApp,
                                              latitudeRad: beta,
                                              obliquityRad: eps)
        eq.distanceAU = dist
        return eq
    }

    private func spherical(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        switch kind {
        case .venus:   return VSOP87Body.venus(jde: jde)
        case .mars:    return VSOP87Body.mars(jde: jde)
        case .jupiter: return VSOP87Body.jupiter(jde: jde)
        case .saturn:  return VSOP87Body.saturn(jde: jde)
        }
    }
}
