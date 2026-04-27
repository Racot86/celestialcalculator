import Foundation

/// Standard navigational-almanac quantities for a body at a given instant + place.
/// Mirrors the columns shown by USNO's celestial-navigation table at
/// https://aa.usno.navy.mil/data/celnavtable so values can be cross-checked offline.
struct AlmanacQuantities {
    /// Universal Time (UT1) Julian Day used for the calculation.
    let jdUT: Double
    /// Apparent geocentric (or topocentric, for Moon) equatorial coordinates of date.
    let equatorial: EquatorialCoordinates
    /// Topocentric horizontal coordinates (true, no refraction applied).
    let horizontalTrue: HorizontalCoordinates
    /// Apparent altitude after Bennett refraction.
    let apparentAltitudeDegrees: Double
    /// Refraction correction applied (degrees, always ≥ 0).
    let refractionDegrees: Double

    /// Greenwich Mean Sidereal Time, hours.
    let gmstHours: Double
    /// Greenwich Apparent Sidereal Time, hours.
    let gastHours: Double
    /// Local Apparent Sidereal Time, hours.
    let lastHours: Double

    /// Greenwich Hour Angle of the body, degrees, 0–360.
    let ghaDegrees: Double
    /// Local Hour Angle of the body, degrees, 0–360.
    let lhaDegrees: Double
    /// Sidereal Hour Angle (= 360 - RA), degrees, 0–360.
    let shaDegrees: Double
}

enum AlmanacCalculator {
    static func compute(bodyID: CelestialBodyID, observer: Observer) -> AlmanacQuantities {
        let body = BodyFactory.body(for: bodyID)
        let jd = JulianDate.julianDay(from: observer.date)
        let eq = body.apparentEquatorial(jdUT: jd)
        let phi = AngleMath.degToRad(observer.latitude)
        let lonRad = AngleMath.degToRad(observer.longitude)

        let gmstRad = SiderealTime.gmst(jdUT: jd)
        let gastRad = SiderealTime.gast(jdUT: jd)
        let lastRad = SiderealTime.last(jdUT: jd, longitudeEastRad: lonRad)

        let h = HorizontalTransform.horizontal(from: eq,
                                               latitudeRad: phi,
                                               localApparentSiderealTimeRad: lastRad)

        // GHA = GAST - RA (degrees, 0..360)
        let raDeg = AngleMath.radToDeg(eq.rightAscension)
        let gastDeg = AngleMath.radToDeg(gastRad)
        let gha = AngleMath.normalizeDegrees(gastDeg - raDeg)
        let lha = AngleMath.normalizeDegrees(gha + observer.longitude)
        let sha = AngleMath.normalizeDegrees(360.0 - raDeg)

        let appAlt = h.altitude > AngleMath.degToRad(-1.0)
            ? Refraction.apparentAltitude(trueAltitudeRad: h.altitude)
            : h.altitude
        let refraction = max(0.0, AngleMath.radToDeg(appAlt - h.altitude))

        return AlmanacQuantities(
            jdUT: jd,
            equatorial: eq,
            horizontalTrue: h,
            apparentAltitudeDegrees: AngleMath.radToDeg(appAlt),
            refractionDegrees: refraction,
            gmstHours: AngleMath.radToDeg(gmstRad) / 15.0,
            gastHours: gastDeg / 15.0,
            lastHours: AngleMath.radToDeg(lastRad) / 15.0,
            ghaDegrees: gha,
            lhaDegrees: lha,
            shaDegrees: sha
        )
    }
}
