import Testing
import Foundation
@testable import celestialcalculator

struct HorizontalTransformTests {
    /// Meeus example 13.b — Venus, 1987 April 10, 19:21:00 UT, Washington DC
    /// φ = +38°55'17", L = 77°03'56" W → Az (from N) = 248°02'01", Alt = 15°07'30"
    @Test func venus_1987Apr10() {
        let phi = AngleMath.degToRad(38.0 + 55.0/60.0 + 17.0/3600.0)
        let lonW = -(77.0 + 3.0/60.0 + 56.0/3600.0)

        // Apparent RA/Dec from Meeus example: α = 23h 09m 16.641s, δ = -6°43'11.61"
        let ra = AngleMath.degToRad((23 + 9.0/60.0 + 16.641/3600.0) * 15.0)
        let dec = AngleMath.degToRad(-(6.0 + 43.0/60.0 + 11.61/3600.0))
        let eq = EquatorialCoordinates(rightAscension: ra, declination: dec)

        var comps = DateComponents()
        comps.timeZone = TimeZone(identifier: "UTC")
        comps.year = 1987; comps.month = 4; comps.day = 10
        comps.hour = 19; comps.minute = 21; comps.second = 0
        let date = Calendar(identifier: .gregorian).date(from: comps)!
        let jd = JulianDate.julianDay(from: date)
        let lst = SiderealTime.last(jdUT: jd, longitudeEastRad: AngleMath.degToRad(lonW))

        let h = HorizontalTransform.horizontal(from: eq, latitudeRad: phi, localApparentSiderealTimeRad: lst)
        let az = h.azimuthDegrees
        let alt = h.altitudeDegrees
        let expectedAz = 248.0 + 2.0/60.0 + 1.0/3600.0
        let expectedAlt = 15.0 + 7.0/60.0 + 30.0/3600.0
        #expect(abs(az - expectedAz) < 0.05)
        #expect(abs(alt - expectedAlt) < 0.05)
    }
}
