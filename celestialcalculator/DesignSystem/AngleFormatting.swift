import Foundation

enum AngleFormatting {
    /// Format degrees as "DDD°MM.M' " (typical navigational format).
    static func bearing(_ degrees: Double) -> String {
        let n = ((degrees.truncatingRemainder(dividingBy: 360.0)) + 360.0).truncatingRemainder(dividingBy: 360.0)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        return String(format: "%03d°%04.1f'", d, m)
    }

    static func altitude(_ degrees: Double) -> String {
        let sign = degrees < 0 ? "-" : "+"
        let n = abs(degrees)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        return String(format: "%@%02d°%04.1f'", sign, d, m)
    }

    /// Hours-Minutes-Seconds for sidereal-time / RA values.
    static func hms(_ hours: Double) -> String {
        let h24 = ((hours.truncatingRemainder(dividingBy: 24.0)) + 24.0).truncatingRemainder(dividingBy: 24.0)
        let h = Int(floor(h24))
        let m = (h24 - Double(h)) * 60.0
        let mi = Int(floor(m))
        let s = (m - Double(mi)) * 60.0
        return String(format: "%02dh %02dm %05.2fs", h, mi, s)
    }

    static func degMinSec(_ degrees: Double) -> String {
        let sign = degrees < 0 ? "-" : "+"
        let n = abs(degrees)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        let mi = Int(floor(m))
        let s = (m - Double(mi)) * 60.0
        return String(format: "%@%03d°%02d'%05.2f\"", sign, d, mi, s)
    }

    /// Latitude as "DD°MM.M'N" or "…S" — degrees zero-padded to 2 digits.
    static func latitudeCompact(_ degrees: Double) -> String {
        let n = abs(degrees)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        let hem = degrees >= 0 ? "N" : "S"
        return String(format: "%02d°%04.1f'%@", d, m, hem)
    }

    /// Longitude as "DDD°MM.M'E" or "…W" — degrees zero-padded to 3 digits.
    static func longitudeCompact(_ degrees: Double) -> String {
        let n = abs(degrees)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        let hem = degrees >= 0 ? "E" : "W"
        return String(format: "%03d°%04.1f'%@", d, m, hem)
    }

    static func cardinal(_ degrees: Double) -> String {
        let dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
                    "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let n = ((degrees.truncatingRemainder(dividingBy: 360.0)) + 360.0).truncatingRemainder(dividingBy: 360.0)
        let i = Int(((n + 11.25) / 22.5)) % 16
        return dirs[i]
    }
}
