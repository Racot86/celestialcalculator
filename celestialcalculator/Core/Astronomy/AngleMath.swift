import Foundation

nonisolated enum AngleMath {
    static func degToRad(_ d: Double) -> Double { d * .pi / 180.0 }
    static func radToDeg(_ r: Double) -> Double { r * 180.0 / .pi }

    static func normalizeDegrees(_ d: Double) -> Double {
        let m = d.truncatingRemainder(dividingBy: 360.0)
        return m < 0 ? m + 360.0 : m
    }

    static func normalizeRadians(_ r: Double) -> Double {
        let twoPi = 2.0 * .pi
        let m = r.truncatingRemainder(dividingBy: twoPi)
        return m < 0 ? m + twoPi : m
    }

    static func normalizeHours(_ h: Double) -> Double {
        let m = h.truncatingRemainder(dividingBy: 24.0)
        return m < 0 ? m + 24.0 : m
    }
}
