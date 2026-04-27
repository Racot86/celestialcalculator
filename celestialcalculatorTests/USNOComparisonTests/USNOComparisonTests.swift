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
        // Modern era — primary navigation use
        ("NewYork-2024-04-27 12:00", "2024-04-27T12:00:00Z", 40.7128, -74.0060),
        ("Sydney-2024-07-15 22:00",  "2024-07-15T22:00:00Z", -33.8688, 151.2093),
        ("Cape-2024-10-01 04:00",    "2024-10-01T04:00:00Z", -33.9249,  18.4241),
        ("Reykjavik-2024-01-15 18:00","2024-01-15T18:00:00Z", 64.1466, -21.9426),
        ("Hawaii-2025-06-21 08:30",  "2025-06-21T08:30:00Z",  19.8968, -155.5828),
        // Long-term validity probes — VSOP87D + IAU 2006 should hold.
        // USNO API only supports up to ~2050, so future-far cases live in the
        // dedicated cross-check below.
        ("Singapore-2050-09-21 03:00","2050-09-21T03:00:00Z",   1.3521, 103.8198),
        ("London-2000-06-21 06:00",  "2000-06-21T06:00:00Z",  51.5074,  -0.1278)
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

    /// True azimuth (Zn) — the nav-critical reading — is held to 0.1' (= 6″)
    /// across every body, every dataset. The supporting equatorial fields are
    /// held to 0.3' to absorb the small extra slack at the 2050 long-term probe.
    private static func tolerance(for id: CelestialBodyID) -> Tol {
        return Tol(zn: 0.002, hc: 0.005, gha: 0.005, dec: 0.005)
    }

    private static func wrapAngle(_ d: Double) -> Double {
        var x = d.truncatingRemainder(dividingBy: 360.0)
        if x > 180  { x -= 360 }
        if x < -180 { x += 360 }
        return x
    }

    private func wrapAngle(_ d: Double) -> Double { Self.wrapAngle(d) }

    /// Offline sanity test for far-future dates the USNO API refuses to compute.
    /// The check is internal: every body must produce a finite, normalized
    /// azimuth and a sensible altitude, with no NaN or runaway values.
    @Test func farFutureSanity() {
        let iso = ISO8601DateFormatter()
        let cases: [(String, String, Double, Double)] = [
            ("Tokyo-2080",        "2080-12-15T07:00:00Z", 35.6762, 139.6503),
            ("Tokyo-2100",        "2100-03-20T21:00:00Z", 35.6762, 139.6503),
            ("Reykjavik-2200",    "2200-06-21T06:00:00Z", 64.1466,  -21.9426)
        ]
        for (label, dateStr, lat, lon) in cases {
            guard let date = iso.date(from: dateStr) else { continue }
            let observer = Observer(date: date, latitude: lat, longitude: lon)
            for id in CompareViewModel.comparableIDs {
                let q = AlmanacCalculator.compute(bodyID: id, observer: observer)
                let az = q.horizontalTrue.azimuthDegrees
                let alt = q.horizontalTrue.altitudeDegrees
                #expect(az.isFinite, "\(label) \(id.displayName) az not finite")
                #expect(alt.isFinite, "\(label) \(id.displayName) alt not finite")
                #expect((-1e-9...360 + 1e-9).contains(az))
                #expect((-90...90).contains(alt))
            }
        }
    }
}
