import Foundation

nonisolated enum JulianDate {
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

    /// ΔT (TT - UT1) in seconds. Espenak & Meeus piecewise polynomial covering
    /// -1999 to +3000 (NASA Eclipse Web Site, 2007). Long-term-valid.
    static func deltaT(jd: Double) -> Double {
        let t = centuriesSinceJ2000(jd: jd)
        let y = 2000.0 + t * 100.0
        let u: Double
        switch y {
        case ..<(-500):
            u = (y - 1820.0) / 100.0
            return -20.0 + 32.0 * u * u
        case -500 ..< 500:
            u = y / 100.0
            return 10583.6 - 1014.41*u + 33.78311*pow(u,2) - 5.952053*pow(u,3)
                 - 0.1798452*pow(u,4) + 0.022174192*pow(u,5) + 0.0090316521*pow(u,6)
        case 500 ..< 1600:
            u = (y - 1000.0) / 100.0
            return 1574.2 - 556.01*u + 71.23472*pow(u,2) + 0.319781*pow(u,3)
                 - 0.8503463*pow(u,4) - 0.005050998*pow(u,5) + 0.0083572073*pow(u,6)
        case 1600 ..< 1700:
            u = y - 1600.0
            return 120.0 - 0.9808*u - 0.01532*pow(u,2) + pow(u,3)/7129.0
        case 1700 ..< 1800:
            u = y - 1700.0
            return 8.83 + 0.1603*u - 0.0059285*pow(u,2) + 0.00013336*pow(u,3) - pow(u,4)/1174000.0
        case 1800 ..< 1860:
            u = y - 1800.0
            return 13.72 - 0.332447*u + 0.0068612*pow(u,2) + 0.0041116*pow(u,3) - 0.00037436*pow(u,4) + 0.0000121272*pow(u,5) - 0.0000001699*pow(u,6) + 0.000000000875*pow(u,7)
        case 1860 ..< 1900:
            u = y - 1860.0
            return 7.62 + 0.5737*u - 0.251754*pow(u,2) + 0.01680668*pow(u,3) - 0.0004473624*pow(u,4) + pow(u,5)/233174.0
        case 1900 ..< 1920:
            u = y - 1900.0
            return -2.79 + 1.494119*u - 0.0598939*pow(u,2) + 0.0061966*pow(u,3) - 0.000197*pow(u,4)
        case 1920 ..< 1941:
            u = y - 1920.0
            return 21.20 + 0.84493*u - 0.076100*pow(u,2) + 0.0020936*pow(u,3)
        case 1941 ..< 1961:
            u = y - 1950.0
            return 29.07 + 0.407*u - pow(u,2)/233.0 + pow(u,3)/2547.0
        case 1961 ..< 1986:
            u = y - 1975.0
            return 45.45 + 1.067*u - pow(u,2)/260.0 - pow(u,3)/718.0
        case 1986 ..< 2005:
            u = y - 2000.0
            return 63.86 + 0.3345*u - 0.060374*pow(u,2) + 0.0017275*pow(u,3) + 0.000651814*pow(u,4) + 0.00002373599*pow(u,5)
        case 2005 ..< 2050:
            u = y - 2000.0
            return 62.92 + 0.32217*u + 0.005589*pow(u,2)
        case 2050 ..< 2150:
            u = (y - 1820.0) / 100.0
            return -20.0 + 32.0*pow(u,2) - 0.5628 * (2150.0 - y)
        default:
            u = (y - 1820.0) / 100.0
            return -20.0 + 32.0 * u * u
        }
    }

    static func jde(from jd: Double) -> Double {
        jd + deltaT(jd: jd) / 86400.0
    }
}
