import Foundation

/// Evaluator for VSOP87D heliocentric ecliptic-of-date series.
/// Returns (lon, lat, r) in radians, radians, AU.
enum VSOP87Engine {
    static func evaluate(L: [[VSOPTerm]],
                         B: [[VSOPTerm]],
                         R: [[VSOPTerm]],
                         jde: Double) -> (lon: Double, lat: Double, r: Double) {
        let tau = (jde - 2451545.0) / 365250.0
        let lon = sumSeries(L, tau: tau)
        let lat = sumSeries(B, tau: tau)
        let r   = sumSeries(R, tau: tau)
        let twoPi = 2.0 * .pi
        var Lw = lon.truncatingRemainder(dividingBy: twoPi)
        if Lw < 0 { Lw += twoPi }
        return (Lw, lat, r)
    }

    private static func sumSeries(_ series: [[VSOPTerm]], tau: Double) -> Double {
        var total = 0.0
        var p = 1.0
        for terms in series {
            var sub = 0.0
            for t in terms { sub += t.a * cos(t.b + t.c * tau) }
            total += sub * p
            p *= tau
        }
        return total
    }
}

enum VSOP87Body {
    static func earth(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L: [VSOP87.earth_L0, VSOP87.earth_L1, VSOP87.earth_L2,
                VSOP87.earth_L3, VSOP87.earth_L4, VSOP87.earth_L5],
            B: [VSOP87.earth_B0, VSOP87.earth_B1, VSOP87.earth_B2,
                VSOP87.earth_B3, VSOP87.earth_B4, VSOP87.earth_B5],
            R: [VSOP87.earth_R0, VSOP87.earth_R1, VSOP87.earth_R2,
                VSOP87.earth_R3, VSOP87.earth_R4, VSOP87.earth_R5],
            jde: jde)
    }
    static func venus(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L: [VSOP87.venus_L0, VSOP87.venus_L1, VSOP87.venus_L2,
                VSOP87.venus_L3, VSOP87.venus_L4, VSOP87.venus_L5],
            B: [VSOP87.venus_B0, VSOP87.venus_B1, VSOP87.venus_B2,
                VSOP87.venus_B3, VSOP87.venus_B4, VSOP87.venus_B5],
            R: [VSOP87.venus_R0, VSOP87.venus_R1, VSOP87.venus_R2,
                VSOP87.venus_R3, VSOP87.venus_R4, VSOP87.venus_R5],
            jde: jde)
    }
    static func mars(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L: [VSOP87.mars_L0, VSOP87.mars_L1, VSOP87.mars_L2,
                VSOP87.mars_L3, VSOP87.mars_L4, VSOP87.mars_L5],
            B: [VSOP87.mars_B0, VSOP87.mars_B1, VSOP87.mars_B2,
                VSOP87.mars_B3, VSOP87.mars_B4, VSOP87.mars_B5],
            R: [VSOP87.mars_R0, VSOP87.mars_R1, VSOP87.mars_R2,
                VSOP87.mars_R3, VSOP87.mars_R4, VSOP87.mars_R5],
            jde: jde)
    }
    static func jupiter(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L: [VSOP87.jupiter_L0, VSOP87.jupiter_L1, VSOP87.jupiter_L2,
                VSOP87.jupiter_L3, VSOP87.jupiter_L4, VSOP87.jupiter_L5],
            B: [VSOP87.jupiter_B0, VSOP87.jupiter_B1, VSOP87.jupiter_B2,
                VSOP87.jupiter_B3, VSOP87.jupiter_B4, VSOP87.jupiter_B5],
            R: [VSOP87.jupiter_R0, VSOP87.jupiter_R1, VSOP87.jupiter_R2,
                VSOP87.jupiter_R3, VSOP87.jupiter_R4, VSOP87.jupiter_R5],
            jde: jde)
    }
    static func saturn(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L: [VSOP87.saturn_L0, VSOP87.saturn_L1, VSOP87.saturn_L2,
                VSOP87.saturn_L3, VSOP87.saturn_L4, VSOP87.saturn_L5],
            B: [VSOP87.saturn_B0, VSOP87.saturn_B1, VSOP87.saturn_B2,
                VSOP87.saturn_B3, VSOP87.saturn_B4, VSOP87.saturn_B5],
            R: [VSOP87.saturn_R0, VSOP87.saturn_R1, VSOP87.saturn_R2,
                VSOP87.saturn_R3, VSOP87.saturn_R4, VSOP87.saturn_R5],
            jde: jde)
    }
}

func vsopSphericalToRect(_ p: (lon: Double, lat: Double, r: Double)) -> (x: Double, y: Double, z: Double) {
    let cb = cos(p.lat)
    return (p.r * cb * cos(p.lon),
            p.r * cb * sin(p.lon),
            p.r * sin(p.lat))
}
