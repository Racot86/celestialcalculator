import Testing
import Foundation
@testable import celestialcalculator

struct SiderealTimeTests {
    /// Meeus example 12.a: 1987 April 10, 0h UT → GMST = 13h 10m 46.3668s
    @Test func gmst_1987Apr10_0h() {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "UTC")
        c.year = 1987; c.month = 4; c.day = 10
        c.hour = 0; c.minute = 0; c.second = 0
        let date = Calendar(identifier: .gregorian).date(from: c)!
        let jd = JulianDate.julianDay(from: date)
        let gmstRad = SiderealTime.gmst(jdUT: jd)
        let gmstHours = AngleMath.radToDeg(gmstRad) / 15.0
        let expected = 13.0 + 10.0/60.0 + 46.3668/3600.0
        #expect(abs(gmstHours - expected) < 1.5/3600.0) // ~1.5 seconds
    }
}
