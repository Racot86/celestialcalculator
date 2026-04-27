import Foundation

/// Planetary positions:
///   • Earth, Jupiter, Saturn — full VSOP87D heliocentric series (sub-arcsecond).
///   • Venus, Mars              — JPL/Standish 1800–2050 Keplerian set
///                                (already < 1' for these inner planets).
/// VSOP87D output is heliocentric ecliptic-of-date, so no extra precession step.
struct Planet: CelestialBody {
    let kind: PlanetKind

    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)

        let earthHelio = vsopSphericalToRect(VSOP87Body.earth(jde: jde))
        var planetHelio = heliocentricOfDate(jde: jde)

        // Light-time iteration (~2 passes is plenty).
        var dx = planetHelio.x - earthHelio.x
        var dy = planetHelio.y - earthHelio.y
        var dz = planetHelio.z - earthHelio.z
        var dist = sqrt(dx*dx + dy*dy + dz*dz)
        let cAUperDay = 173.144632674
        for _ in 0..<2 {
            let tau = dist / cAUperDay
            planetHelio = heliocentricOfDate(jde: jde - tau)
            dx = planetHelio.x - earthHelio.x
            dy = planetHelio.y - earthHelio.y
            dz = planetHelio.z - earthHelio.z
            dist = sqrt(dx*dx + dy*dy + dz*dz)
        }

        // Geocentric ecliptic of date → apparent (apply nutation in longitude).
        let lambda = AngleMath.normalizeRadians(atan2(dy, dx))
        let beta = atan2(dz, sqrt(dx*dx + dy*dy))
        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let lambdaApp = lambda + dpsi
        let eps = Obliquity.trueObliquity(jde: jde)
        var eq = EclipticToEquatorial.convert(longitudeRad: lambdaApp,
                                              latitudeRad: beta,
                                              obliquityRad: eps)
        eq.distanceAU = dist
        return eq
    }

    /// Heliocentric ecliptic-of-date rectangular for the body, AU.
    private func heliocentricOfDate(jde: Double) -> (x: Double, y: Double, z: Double) {
        switch kind {
        case .jupiter:
            return vsopSphericalToRect(VSOP87Body.jupiter(jde: jde))
        case .saturn:
            return vsopSphericalToRect(VSOP87Body.saturn(jde: jde))
        case .venus:
            return standishHelioOfDate(elements: .venus, jde: jde)
        case .mars:
            return standishHelioOfDate(elements: .mars, jde: jde)
        }
    }

    // MARK: - Standish Keplerian (Venus, Mars)

    private struct Elements {
        let a0: Double, aDot: Double
        let e0: Double, eDot: Double
        let I0: Double, IDot: Double
        let L0: Double, LDot: Double
        let wbar0: Double, wbarDot: Double
        let omg0: Double, omgDot: Double

        static let venus = Elements(
            a0: 0.72333566, aDot: 0.00000390,
            e0: 0.00677672, eDot: -0.00004107,
            I0: 3.39467605, IDot: -0.00078890,
            L0: 181.97909950, LDot: 58517.81538729,
            wbar0: 131.60246718, wbarDot: 0.00268329,
            omg0: 76.67984255, omgDot: -0.27769418
        )
        static let mars = Elements(
            a0: 1.52371034, aDot: 0.00001847,
            e0: 0.09339410, eDot: 0.00007882,
            I0: 1.84969142, IDot: -0.00813131,
            L0: -4.55343205, LDot: 19140.30268499,
            wbar0: -23.94362959, wbarDot: 0.44441088,
            omg0: 49.55953891, omgDot: -0.29257343
        )
    }

    /// Standish heliocentric position, then precess J2000 → of-date longitude.
    private func standishHelioOfDate(elements e: Elements, jde: Double) -> (x: Double, y: Double, z: Double) {
        let T = (jde - JulianDate.j2000) / 36525.0
        let a = e.a0 + e.aDot * T
        let ecc = e.e0 + e.eDot * T
        let I = AngleMath.degToRad(e.I0 + e.IDot * T)
        let L = e.L0 + e.LDot * T
        let wbar = e.wbar0 + e.wbarDot * T
        let omega = AngleMath.degToRad(e.omg0 + e.omgDot * T)

        var M = L - wbar
        M = M.truncatingRemainder(dividingBy: 360.0)
        if M < -180 { M += 360 } else if M > 180 { M -= 360 }
        let Mr = AngleMath.degToRad(M)
        let argPeri = AngleMath.degToRad(wbar) - omega

        var E = Mr + ecc * sin(Mr)
        for _ in 0..<10 {
            let dE = (E - ecc * sin(E) - Mr) / (1 - ecc * cos(E))
            E -= dE
            if abs(dE) < 1e-10 { break }
        }

        let xPrime = a * (cos(E) - ecc)
        let yPrime = a * sqrt(1 - ecc*ecc) * sin(E)

        let cw = cos(argPeri), sw = sin(argPeri)
        let cO = cos(omega),   sO = sin(omega)
        let cI = cos(I),       sI = sin(I)
        var x = (cw*cO - sw*sO*cI)*xPrime + (-sw*cO - cw*sO*cI)*yPrime
        var y = (cw*sO + sw*cO*cI)*xPrime + (-sw*sO + cw*cO*cI)*yPrime
        let z = (sw*sI)*xPrime + (cw*sI)*yPrime

        // Precess J2000 ecliptic → ecliptic of date by rotating about Z by general
        // precession in longitude. (Earth uses VSOP87 directly so doesn't need this.)
        let precessLon = AngleMath.degToRad(1.396971278 * T + 0.0003086 * T * T)
        let cp = cos(precessLon), sp = sin(precessLon)
        let xR = x * cp - y * sp
        let yR = x * sp + y * cp
        x = xR; y = yR
        return (x, y, z)
    }
}

private func vsopSphericalToRect(_ p: (lon: Double, lat: Double, r: Double)) -> (x: Double, y: Double, z: Double) {
    let cb = cos(p.lat)
    return (p.r * cb * cos(p.lon),
            p.r * cb * sin(p.lon),
            p.r * sin(p.lat))
}
