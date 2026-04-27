import Testing
import Foundation
@testable import celestialcalculator

struct JulianDateTests {
    @Test func meeusExample7a_1957Oct4_19h26m24s() {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "UTC")
        c.year = 1957; c.month = 10; c.day = 4
        c.hour = 19; c.minute = 26; c.second = 24
        let date = Calendar(identifier: .gregorian).date(from: c)!
        let jd = JulianDate.julianDay(from: date)
        // Meeus example 7.a: JD = 2436116.31
        #expect(abs(jd - 2436116.31) < 1e-2)
    }

    @Test func j2000Epoch() {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "UTC")
        c.year = 2000; c.month = 1; c.day = 1
        c.hour = 12; c.minute = 0; c.second = 0
        let date = Calendar(identifier: .gregorian).date(from: c)!
        let jd = JulianDate.julianDay(from: date)
        #expect(abs(jd - 2451545.0) < 1e-6)
    }
}
