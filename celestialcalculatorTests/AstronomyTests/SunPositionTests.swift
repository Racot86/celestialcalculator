import Testing
import Foundation
@testable import celestialcalculator

struct SunPositionTests {
    /// Meeus example 25.b: 1992 Oct 13, 0h TD.
    /// Apparent RA ≈ 13h 13m 30.749s, Dec ≈ -7°47'01.74"
    @Test func sun_1992Oct13() {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "UTC")
        c.year = 1992; c.month = 10; c.day = 13
        c.hour = 0; c.minute = 0; c.second = 0
        let date = Calendar(identifier: .gregorian).date(from: c)!
        let jd = JulianDate.julianDay(from: date)
        let eq = Sun().apparentEquatorial(jdUT: jd)
        let raHours = AngleMath.radToDeg(eq.rightAscension) / 15.0
        let decDeg = AngleMath.radToDeg(eq.declination)
        let expectedRA = 13.0 + 13.0/60.0 + 30.749/3600.0
        let expectedDec = -(7.0 + 47.0/60.0 + 1.74/3600.0)
        #expect(abs(raHours - expectedRA) < 0.001)         // ~3.6 arc-seconds in time
        #expect(abs(decDeg - expectedDec) < 0.01)
    }
}
