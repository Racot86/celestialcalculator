import Foundation

/// Evaluator for VSOP87D heliocentric ecliptic-of-date series.
/// Returns (L, B, R) in radians, radians, AU.
enum VSOP87Engine {
    static func evaluate(L_series: [[VSOPTerm]],
                         B_series: [[VSOPTerm]],
                         R_series: [[VSOPTerm]],
                         jde: Double) -> (lon: Double, lat: Double, r: Double) {
        let tau = (jde - 2451545.0) / 365250.0
        let L = sumSeries(L_series, tau: tau)
        let B = sumSeries(B_series, tau: tau)
        let R = sumSeries(R_series, tau: tau)
        let twoPi = 2.0 * .pi
        var Lw = L.truncatingRemainder(dividingBy: twoPi)
        if Lw < 0 { Lw += twoPi }
        return (Lw, B, R)
    }

    /// Σₙ τⁿ · Σ A · cos(B + C · τ)
    private static func sumSeries(_ series: [[VSOPTerm]], tau: Double) -> Double {
        var total = 0.0
        var tauPower = 1.0
        for terms in series {
            var sub = 0.0
            for term in terms {
                sub += term.a * cos(term.b + term.c * tau)
            }
            total += sub * tauPower
            tauPower *= tau
        }
        return total
    }
}

/// VSOP87D positions for the three bodies we ship the full series for.
enum VSOP87Body {
    static func earth(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L_series: [VSOP87.earth_L0, VSOP87.earth_L1, VSOP87.earth_L2,
                       VSOP87.earth_L3, VSOP87.earth_L4, VSOP87.earth_L5],
            B_series: [VSOP87.earth_B0, VSOP87.earth_B1, VSOP87.earth_B2,
                       VSOP87.earth_B3, VSOP87.earth_B4, VSOP87.earth_B5],
            R_series: [VSOP87.earth_R0, VSOP87.earth_R1, VSOP87.earth_R2,
                       VSOP87.earth_R3, VSOP87.earth_R4, VSOP87.earth_R5],
            jde: jde
        )
    }

    static func jupiter(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L_series: [VSOP87.jupiter_L0, VSOP87.jupiter_L1, VSOP87.jupiter_L2,
                       VSOP87.jupiter_L3, VSOP87.jupiter_L4, VSOP87.jupiter_L5],
            B_series: [VSOP87.jupiter_B0, VSOP87.jupiter_B1, VSOP87.jupiter_B2,
                       VSOP87.jupiter_B3, VSOP87.jupiter_B4, VSOP87.jupiter_B5],
            R_series: [VSOP87.jupiter_R0, VSOP87.jupiter_R1, VSOP87.jupiter_R2,
                       VSOP87.jupiter_R3, VSOP87.jupiter_R4, VSOP87.jupiter_R5],
            jde: jde
        )
    }

    static func saturn(jde: Double) -> (lon: Double, lat: Double, r: Double) {
        VSOP87Engine.evaluate(
            L_series: [VSOP87.saturn_L0, VSOP87.saturn_L1, VSOP87.saturn_L2,
                       VSOP87.saturn_L3, VSOP87.saturn_L4, VSOP87.saturn_L5],
            B_series: [VSOP87.saturn_B0, VSOP87.saturn_B1, VSOP87.saturn_B2,
                       VSOP87.saturn_B3, VSOP87.saturn_B4, VSOP87.saturn_B5],
            R_series: [VSOP87.saturn_R0, VSOP87.saturn_R1, VSOP87.saturn_R2,
                       VSOP87.saturn_R3, VSOP87.saturn_R4, VSOP87.saturn_R5],
            jde: jde
        )
    }
}

/// Convert heliocentric ecliptic spherical (L, B, R) → rectangular (X, Y, Z).
func vsopSphericalToRect(lon: Double, lat: Double, r: Double) -> (x: Double, y: Double, z: Double) {
    let cb = cos(lat)
    return (r * cb * cos(lon), r * cb * sin(lon), r * sin(lat))
}
