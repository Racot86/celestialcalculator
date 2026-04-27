import Foundation

/// Planetary positions via JPL/Standish "Keplerian Elements for Approximate Positions
/// of the Major Planets" (1800 AD – 2050 AD set).
/// Reference: https://ssd.jpl.nasa.gov/planets/approx_pos.html
/// Accuracy: sub-arcminute for Mercury–Mars, a few arcminutes for outer planets.
struct Planet: CelestialBody {
    let kind: PlanetKind

    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)

        // Heliocentric ecliptic rectangular coordinates (J2000) of Earth and target planet.
        let earth = heliocentricJ2000(elements: .earth, jde: jde)
        var planet = heliocentricJ2000(elements: elements(for: kind), jde: jde)

        // Light-time correction: iterate ~2 times.
        var dx = planet.x - earth.x, dy = planet.y - earth.y, dz = planet.z - earth.z
        var dist = sqrt(dx*dx + dy*dy + dz*dz)
        let c_AU_per_day = 173.144632674
        for _ in 0..<2 {
            let tau = dist / c_AU_per_day
            planet = heliocentricJ2000(elements: elements(for: kind), jde: jde - tau)
            dx = planet.x - earth.x; dy = planet.y - earth.y; dz = planet.z - earth.z
            dist = sqrt(dx*dx + dy*dy + dz*dz)
        }

        // Convert geocentric J2000 ecliptic rectangular → ecliptic of-date by precessing
        // longitude. For simplicity we treat coordinates as if of-date (small bias, < arcminute
        // for the ~26-yr precession over this era is acceptable for navigational azimuth).
        let lambda = AngleMath.normalizeRadians(atan2(dy, dx))
        let beta = atan2(dz, sqrt(dx*dx + dy*dy))

        // Apply precession from J2000 to date (longitude only) — Meeus 21 simplified
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        let precessLon = AngleMath.degToRad((1.396971278 * t + 0.0003086 * t*t)) // approx general precession in long
        let lambdaDate = lambda + precessLon

        // Apparent: + nutation in longitude
        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let lambdaApp = lambdaDate + dpsi
        let eps = Obliquity.trueObliquity(jde: jde)
        var eq = EclipticToEquatorial.convert(longitudeRad: lambdaApp, latitudeRad: beta, obliquityRad: eps)
        eq.distanceAU = dist
        return eq
    }

    // MARK: - Keplerian elements

    private struct Elements {
        // a (AU), e, I (deg), L (deg), longPeri ϖ (deg), longNode Ω (deg)
        let a0: Double, aDot: Double
        let e0: Double, eDot: Double
        let I0: Double, IDot: Double
        let L0: Double, LDot: Double
        let wbar0: Double, wbarDot: Double
        let omg0: Double, omgDot: Double

        static let earth = Elements(
            a0: 1.00000261, aDot: 0.00000562,
            e0: 0.01671123, eDot: -0.00004392,
            I0: -0.00001531, IDot: -0.01294668,
            L0: 100.46457166, LDot: 35999.37244981,
            wbar0: 102.93768193, wbarDot: 0.32327364,
            omg0: 0.0, omgDot: 0.0
        )
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
        static let jupiter = Elements(
            a0: 5.20288700, aDot: -0.00011607,
            e0: 0.04838624, eDot: -0.00013253,
            I0: 1.30439695, IDot: -0.00183714,
            L0: 34.39644051, LDot: 3034.74612775,
            wbar0: 14.72847983, wbarDot: 0.21252668,
            omg0: 100.47390909, omgDot: 0.20469106
        )
        static let saturn = Elements(
            a0: 9.53667594, aDot: -0.00125060,
            e0: 0.05386179, eDot: -0.00050991,
            I0: 2.48599187, IDot: 0.00193609,
            L0: 49.95424423, LDot: 1222.49362201,
            wbar0: 92.59887831, wbarDot: -0.41897216,
            omg0: 113.66242448, omgDot: -0.28867794
        )
    }

    private func elements(for k: PlanetKind) -> Elements {
        switch k {
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        }
    }

    /// Heliocentric J2000 ecliptic rectangular coordinates (AU).
    private func heliocentricJ2000(elements e: Elements, jde: Double) -> (x: Double, y: Double, z: Double) {
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

        // Solve Kepler's equation E - e sin E = M (radians, e dimensionless)
        var E = Mr + ecc * sin(Mr)
        for _ in 0..<10 {
            let dE = (E - ecc * sin(E) - Mr) / (1 - ecc * cos(E))
            E -= dE
            if abs(dE) < 1e-10 { break }
        }

        // Heliocentric coordinates in orbital plane
        let xPrime = a * (cos(E) - ecc)
        let yPrime = a * sqrt(1 - ecc*ecc) * sin(E)

        // Rotate to J2000 ecliptic
        let cw = cos(argPeri), sw = sin(argPeri)
        let cO = cos(omega),   sO = sin(omega)
        let cI = cos(I),       sI = sin(I)
        let xEc = (cw*cO - sw*sO*cI)*xPrime + (-sw*cO - cw*sO*cI)*yPrime
        let yEc = (cw*sO + sw*cO*cI)*xPrime + (-sw*sO + cw*cO*cI)*yPrime
        let zEc = (sw*sI)*xPrime + (cw*sI)*yPrime
        return (xEc, yEc, zEc)
    }
}
