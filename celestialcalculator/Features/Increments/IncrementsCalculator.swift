import Foundation

/// "Increments and Corrections" tables — what mariners use to interpolate the
/// hourly tabular GHA / Dec values published in the Nautical Almanac to a
/// specific minute and second of UT.
///
///   • **Sun / planets** advance at exactly **15° per hour** (1° per 4 min,
///     0.25′ per second of time).
///   • **Aries** (sidereal point) advances at **15° 02′ 27.85″ per hour** —
///     about 0.274 % faster than the Sun. IAU value:
///         15.04106864° / hour  =  0.250684477′ per second of time.
///   • **v / d corrections** scale the published hourly v or d rate
///     (arc-minutes per hour) by the elapsed minutes-of-the-hour:
///         correction = v · (m / 60)
///     rounded to 0.1′ as in the published almanac.
nonisolated enum IncrementsCalculator {
    /// Sun / planets increment for `m` minutes + `s` seconds, in arc-minutes.
    static func sunPlanetsArcmin(min m: Int, sec s: Int) -> Double {
        Double(m) * 15.0 + Double(s) * 0.25
    }

    /// Aries increment for `m` minutes + `s` seconds, in arc-minutes.
    static func ariesArcmin(min m: Int, sec s: Int) -> Double {
        let totalSec = Double(m) * 60.0 + Double(s)
        return totalSec * (15.04106864 / 3600.0) * 60.0    // arcmin = sec × ° × 60
    }

    /// v/d correction for the published `v` (or `d`) rate at minute `m` of the
    /// hour. Returns arc-minutes (not rounded).
    static func vdCorrectionArcmin(v: Double, min m: Int) -> Double {
        v * Double(m) / 60.0
    }

    /// Round to 0.1 arcmin, half-up.
    static func roundToTenth(_ value: Double) -> Double {
        (value * 10.0).rounded() / 10.0
    }

    /// Format an arc-minute value as "DD MM.M" — the column layout used by
    /// the printed almanac, where the degree count is the integer part of
    /// `arcmin / 60` and the minutes part is `arcmin mod 60`, to one tenth.
    static func formatDM(arcmin: Double) -> (deg: Int, arcminInDeg: Double) {
        let total = roundToTenth(arcmin)
        let deg = Int(floor(total / 60.0 + 1e-9))
        let amin = total - Double(deg) * 60.0
        return (deg, amin)
    }
}
