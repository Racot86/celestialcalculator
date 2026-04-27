import Foundation

/// Catalog star → apparent equatorial of date.
/// Steps: J2000 catalog → proper motion to epoch → IAU precession → nutation → annual aberration.
nonisolated struct Star: CelestialBody {
    let catalogIndex: Int

    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)
        let entry = NavigationalStars.all[catalogIndex]

        let yearsSinceJ2000 = (jde - JulianDate.j2000) / 365.25
        // Proper motion: pmRA in seconds-of-time/year, pmDec in arcsec/year (J2000)
        let raJ2000 = AngleMath.degToRad(entry.raJ2000Deg) + AngleMath.degToRad(entry.pmRAArcsecPerYear / 3600.0) / cos(AngleMath.degToRad(entry.decJ2000Deg)) * yearsSinceJ2000
        let decJ2000 = AngleMath.degToRad(entry.decJ2000Deg) + AngleMath.degToRad(entry.pmDecArcsecPerYear / 3600.0) * yearsSinceJ2000

        // Precession from J2000 to date (Meeus 21)
        let (raDate, decDate) = Precession.precessJ2000ToDate(raRad: raJ2000, decRad: decJ2000, jde: jde)

        // Nutation in RA/Dec (Meeus 23.1)
        let (dpsi, deps) = Nutation.nutation(jde: jde)
        let eps = Obliquity.meanObliquity(jde: jde)
        let raN = raDate + (cos(eps) + sin(eps) * sin(raDate) * tan(decDate)) * dpsi
                          - (cos(raDate) * tan(decDate)) * deps
        let decN = decDate + sin(eps) * cos(raDate) * dpsi + sin(raDate) * deps

        // Annual aberration (Meeus 23.2)
        let (dRaA, dDecA) = Aberration.annualAberration(raRad: raN, decRad: decN, jde: jde)
        let raApp = AngleMath.normalizeRadians(raN + dRaA)
        let decApp = decN + dDecA

        return EquatorialCoordinates(rightAscension: raApp, declination: decApp)
    }
}
