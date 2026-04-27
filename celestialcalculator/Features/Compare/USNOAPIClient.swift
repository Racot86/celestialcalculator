import Foundation

/// USNO Astronomical Applications API client.
/// USED FOR DEVELOPER VERIFICATION ONLY — the rest of the app is fully offline.
///
/// Endpoint: GET https://aa.usno.navy.mil/api/celnav
///   ?date=YYYY-MM-DD&time=HH:MM:SS&coords=LAT,LON&body=Sun
/// The endpoint returns *all* navigational bodies (Sun, Moon, planets, navigational
/// stars) in a single response, so one call covers every comparable row.
struct USNOResult {
    let azimuthDegrees: Double
    let altitudeDegrees: Double
    let ghaDegrees: Double?
    let decDegrees: Double?
}

enum USNOError: Error, LocalizedError {
    case badStatus(Int)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .badStatus(let s): return "USNO returned HTTP \(s)"
        case .decodingFailed(let s): return "USNO decode failed: \(s)"
        }
    }
}

actor USNOAPIClient {
    private let session: URLSession
    private let host = "aa.usno.navy.mil"

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    /// Fetch all navigational bodies in one request.
    /// Returns a dictionary keyed by normalized USNO body name.
    func fetchAll(observer: Observer) async throws -> [String: USNOResult] {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = host
        comps.path = "/api/celnav"
        let cal = Calendar(identifier: .gregorian)
        let utc = TimeZone(identifier: "UTC")!
        let dc = cal.dateComponents(in: utc, from: observer.date)
        let dateStr = String(format: "%04d-%02d-%02d", dc.year ?? 2000, dc.month ?? 1, dc.day ?? 1)
        let timeStr = String(format: "%02d:%02d:%02d", dc.hour ?? 0, dc.minute ?? 0, dc.second ?? 0)
        let coordsStr = String(format: "%.6f,%.6f", observer.latitude, observer.longitude)

        comps.queryItems = [
            .init(name: "date", value: dateStr),
            .init(name: "time", value: timeStr),
            .init(name: "coords", value: coordsStr),
            .init(name: "body", value: "Sun")
        ]

        let url = comps.url!
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw USNOError.badStatus(0) }
        guard 200..<300 ~= http.statusCode else { throw USNOError.badStatus(http.statusCode) }

        return try parseAll(data: data)
    }

    private func parseAll(data: Data) throws -> [String: USNOResult] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let props = root["properties"] as? [String: Any],
              let rows = props["data"] as? [[String: Any]] else {
            throw USNOError.decodingFailed("unexpected shape")
        }

        var out: [String: USNOResult] = [:]
        for row in rows {
            guard let name = row["object"] as? String,
                  let almanac = row["almanac_data"] as? [String: Any] else { continue }
            guard let zn = (almanac["zn"] as? Double) ?? Double(almanac["zn"] as? String ?? ""),
                  let hc = (almanac["hc"] as? Double) ?? Double(almanac["hc"] as? String ?? "") else {
                continue
            }
            let gha = (almanac["gha"] as? Double) ?? Double(almanac["gha"] as? String ?? "")
            let dec = (almanac["dec"] as? Double) ?? Double(almanac["dec"] as? String ?? "")
            out[Self.normalize(name)] = USNOResult(
                azimuthDegrees: zn,
                altitudeDegrees: hc,
                ghaDegrees: gha,
                decDegrees: dec
            )
        }
        return out
    }

    /// Normalize body name for matching: lowercase, drop spaces and apostrophes.
    static func normalize(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
    }

    /// Map our internal body to the USNO key.
    static func usnoKey(for id: CelestialBodyID) -> String {
        switch id {
        case .sun: return "sun"
        case .moon: return "moon"
        case .planet(let p):
            switch p {
            case .venus: return "venus"
            case .mars: return "mars"
            case .jupiter: return "jupiter"
            case .saturn: return "saturn"
            }
        case .star(let i):
            let name = NavigationalStars.all[i].name
            // USNO uses "Alnair" for "Al Na'ir" and "Rigil Kentaurus" for "Rigil Kent"
            switch name {
            case "Al Na'ir": return "alnair"
            case "Rigil Kent": return "rigilkentaurus"
            case "Zubenelgenubi": return "zubenelgenubi"
            default: return normalize(name)
            }
        }
    }
}
