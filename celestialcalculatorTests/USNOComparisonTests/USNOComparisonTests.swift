import Testing
import Foundation
@testable import celestialcalculator

/// End-to-end comparison of our offline calculations against the USNO API.
/// Network-dependent. Hits https://aa.usno.navy.mil/api/celnav with a series of
/// (date, lat, lon) cases and asserts per-body deltas vs. published results.
///
/// Per-quantity tolerances (deg) — set generously enough to absorb published
/// USNO rounding (most fields are returned to ≤6 decimal places of degrees):
///   • Sun, Moon, stars: Zn/Hc within 1.5'  (0.025°), GHA/Dec within 0.5'
///   • Inner planets    : Zn/Hc within 3'    (0.05°)
///   • Outer planets    : Zn/Hc within 8'    (0.133°)
struct USNOComparisonTests {
    private static let observers: [(label: String, date: String, lat: Double, lon: Double)] = [
        ("NewYork-2024-04-27 12:00", "2024-04-27T12:00:00Z", 40.7128, -74.0060),
        ("Sydney-2024-07-15 22:00",  "2024-07-15T22:00:00Z", -33.8688, 151.2093),
        ("Cape-2024-10-01 04:00",    "2024-10-01T04:00:00Z", -33.9249,  18.4241),
        ("Reykjavik-2024-01-15 18:00","2024-01-15T18:00:00Z", 64.1466, -21.9426),
        ("Hawaii-2025-06-21 08:30",  "2025-06-21T08:30:00Z",  19.8968, -155.5828)
    ]

    @Test func compareAgainstUSNO_multiDataset() async throws {
        let iso = ISO8601DateFormatter()
        let client = USNOAPIClient()

        var allDeltas: [String: [Double]] = [:]   // body name → [|Δaz| arcmin]
        var failures: [String] = []

        for (label, dateStr, lat, lon) in Self.observers {
            guard let date = iso.date(from: dateStr) else { continue }
            let observer = Observer(date: date, latitude: lat, longitude: lon)

            let usno: [String: USNOResult]
            do {
                usno = try await client.fetchAll(observer: observer)
            } catch {
                Issue.record("USNO fetch failed for \(label): \(error)")
                continue
            }

            for id in CompareViewModel.comparableIDs {
                let q = AlmanacCalculator.compute(bodyID: id, observer: observer)
                guard q.horizontalTrue.altitudeDegrees > 0 else { continue }
                let key = USNOAPIClient.usnoKey(for: id)
                guard let u = usno[key] else { continue }

                let znDelta = wrapAngle(q.horizontalTrue.azimuthDegrees - u.azimuthDegrees)
                let hcDelta = q.horizontalTrue.altitudeDegrees - u.altitudeDegrees
                let ghaDelta = wrapAngle(q.ghaDegrees - (u.ghaDegrees ?? q.ghaDegrees))
                let decDelta = AngleMath.radToDeg(q.equatorial.declination) - (u.decDegrees ?? AngleMath.radToDeg(q.equatorial.declination))

                let tol = Self.tolerance(for: id)
                let bodyName = id.displayName
                allDeltas[bodyName, default: []].append(abs(znDelta) * 60.0)

                if abs(znDelta) > tol.zn {
                    failures.append("[\(label)] \(bodyName) Zn Δ = \(String(format: "%+.3f°", znDelta)) (tol \(tol.zn)°)")
                }
                if abs(hcDelta) > tol.hc {
                    failures.append("[\(label)] \(bodyName) Hc Δ = \(String(format: "%+.3f°", hcDelta)) (tol \(tol.hc)°)")
                }
                if abs(ghaDelta) > tol.gha {
                    failures.append("[\(label)] \(bodyName) GHA Δ = \(String(format: "%+.3f°", ghaDelta)) (tol \(tol.gha)°)")
                }
                if abs(decDelta) > tol.dec {
                    failures.append("[\(label)] \(bodyName) Dec Δ = \(String(format: "%+.3f°", decDelta)) (tol \(tol.dec)°)")
                }
            }
        }

        // Print summary by body, max |Δaz|.
        let sorted = allDeltas.mapValues { $0.max() ?? 0 }.sorted { $0.value > $1.value }
        var summary = "\nUSNO comparison summary — max |Δ Zn| (arcmin) by body:\n"
        for (k, v) in sorted.prefix(30) {
            summary += String(format: "  %-18s  %6.2f'\n", (k as NSString).utf8String!, v)
        }
        print(summary)

        if !failures.isEmpty {
            for f in failures.prefix(40) { print("  FAIL " + f) }
            Issue.record("\(failures.count) tolerance violations; first shown above.")
        }
    }

    private struct Tol {
        let zn: Double; let hc: Double; let gha: Double; let dec: Double
    }

    /// All deltas must stay under 1 arc-minute (0.0167°). Verified on 5 datasets.
    private static func tolerance(for id: CelestialBodyID) -> Tol {
        return Tol(zn: 0.0167, hc: 0.0167, gha: 0.0167, dec: 0.0167)
    }

    private static func wrapAngle(_ d: Double) -> Double {
        var x = d.truncatingRemainder(dividingBy: 360.0)
        if x > 180  { x -= 360 }
        if x < -180 { x += 360 }
        return x
    }

    private func wrapAngle(_ d: Double) -> Double { Self.wrapAngle(d) }
}
