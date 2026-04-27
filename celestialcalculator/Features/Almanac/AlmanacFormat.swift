import Foundation

enum AlmanacFormat {
    /// "ddd°mm.m'" GHA-style with no sign.
    static func gha(_ degrees: Double) -> String {
        let n = ((degrees.truncatingRemainder(dividingBy: 360.0)) + 360.0)
                .truncatingRemainder(dividingBy: 360.0)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        return String(format: "%03d°%04.1f'", d, m)
    }

    /// "N dd°mm.m'" / "S dd°mm.m'"
    static func dec(_ degrees: Double) -> String {
        let s = degrees >= 0 ? "N" : "S"
        let n = abs(degrees)
        let d = Int(floor(n))
        let m = (n - Double(d)) * 60.0
        return String(format: "%@ %02d°%04.1f'", s, d, m)
    }

    /// "+v.v" arc-min/h
    static func vd(_ minPerHour: Double?) -> String {
        guard let v = minPerHour else { return "—" }
        return String(format: "%+.1f", v)
    }

    static func sd(_ minutes: Double?) -> String {
        guard let m = minutes else { return "—" }
        return String(format: "%.1f'", m)
    }

    /// "HH:MM" UTC, or "—"
    static func hhmm(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
