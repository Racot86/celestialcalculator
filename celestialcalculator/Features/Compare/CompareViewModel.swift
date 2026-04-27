import Foundation
import Observation

struct CompareRow: Identifiable {
    let id: String
    let bodyID: CelestialBodyID
    let displayName: String
    let appAzimuth: Double
    let appAltitude: Double
    var usno: USNOResult?
    var error: String?

    var azimuthDelta: Double? {
        guard let u = usno else { return nil }
        var d = appAzimuth - u.azimuthDegrees
        if d > 180 { d -= 360 }
        if d < -180 { d += 360 }
        return d
    }

    var altitudeDelta: Double? {
        guard let u = usno else { return nil }
        return appAltitude - u.altitudeDegrees
    }
}

@Observable
final class CompareViewModel {
    var observerStore: ObserverStore
    var rows: [CompareRow] = []
    var isFetching: Bool = false
    var lastError: String?

    private let client = USNOAPIClient()

    init(observerStore: ObserverStore) {
        self.observerStore = observerStore
        self.rows = Self.buildLocalRows(observerStore.observer)
    }

    /// Bodies eligible for USNO comparison: Sun, Moon, 4 planets, all 57 nav stars.
    static let comparableIDs: [CelestialBodyID] = {
        var ids: [CelestialBodyID] = [.sun, .moon]
        ids += PlanetKind.allCases.map { .planet($0) }
        ids += (0..<NavigationalStars.count).map { .star($0) }
        return ids
    }()

    func refreshLocal() {
        rows = Self.buildLocalRows(observerStore.observer)
    }

    /// USNO `/api/celnav` only returns bodies currently above the horizon, so
    /// we filter to the same set for fair comparison.
    private static func buildLocalRows(_ observer: Observer) -> [CompareRow] {
        comparableIDs.compactMap { id in
            let h = BodyFactory.body(for: id).horizontalCoordinates(for: observer)
            guard h.altitudeDegrees > 0 else { return nil }
            return CompareRow(id: id.id,
                              bodyID: id,
                              displayName: id.displayName,
                              appAzimuth: h.azimuthDegrees,
                              appAltitude: h.altitudeDegrees)
        }
    }

    @MainActor
    func fetchAll() async {
        isFetching = true
        lastError = nil
        rows = Self.buildLocalRows(observerStore.observer)

        do {
            let dict = try await client.fetchAll(observer: observerStore.observer)
            for index in rows.indices {
                let key = USNOAPIClient.usnoKey(for: rows[index].bodyID)
                if let result = dict[key] {
                    rows[index].usno = result
                } else {
                    rows[index].error = "not in USNO response"
                }
            }
        } catch {
            lastError = error.localizedDescription
        }
        isFetching = false
    }
}
