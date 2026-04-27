import Foundation

enum JulianDate {
    static let j2000: Double = 2451545.0

    static func julianDay(from date: Date) -> Double {
        let cal = Calendar(identifier: .gregorian)
        let c = cal.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        var year = c.year ?? 2000
        var month = c.month ?? 1
        let day = Double(c.day ?? 1)
            + Double(c.hour ?? 0) / 24.0
            + Double(c.minute ?? 0) / 1440.0
            + (Double(c.second ?? 0) + Double(c.nanosecond ?? 0) / 1e9) / 86400.0

        if month <= 2 { year -= 1; month += 12 }
        let A = (year / 100)
        let B = 2 - A + (A / 4)
        let jd = floor(365.25 * Double(year + 4716))
            + floor(30.6001 * Double(month + 1))
            + day + Double(B) - 1524.5
        return jd
    }

    static func centuriesSinceJ2000(jd: Double) -> Double {
        (jd - j2000) / 36525.0
    }

    /// Approximate ΔT (TT - UT1) in seconds. Polynomial valid for modern era (~2005-2050).
    static func deltaT(jd: Double) -> Double {
        let t = centuriesSinceJ2000(jd: jd)
        let y = 2000.0 + t * 100.0
        // Espenak & Meeus polynomial for 2005..2050
        if y >= 2005 && y < 2050 {
            let tt = y - 2000.0
            return 62.92 + 0.32217 * tt + 0.005589 * tt * tt
        }
        if y >= 1986 && y < 2005 {
            let tt = y - 2000.0
            return 63.86 + 0.3345 * tt - 0.060374 * tt*tt + 0.0017275 * pow(tt,3) + 0.000651814 * pow(tt,4) + 0.00002373599 * pow(tt,5)
        }
        if y >= 2050 && y < 2150 {
            let u = (y - 1820.0) / 100.0
            return -20.0 + 32.0 * u * u - 0.5628 * (2150.0 - y)
        }
        // fallback (rough)
        let u = (y - 1820.0) / 100.0
        return -20.0 + 32.0 * u * u
    }

    static func jde(from jd: Double) -> Double {
        jd + deltaT(jd: jd) / 86400.0
    }
}
