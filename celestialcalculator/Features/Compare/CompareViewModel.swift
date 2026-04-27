import Foundation
import Observation

struct CompareRow: Identifiable {
    let id: String
    let bodyID: CelestialBodyID
    let displayName: String

    /// App-side calculated values.
    let appZn: Double          // true azimuth, deg
    let appHc: Double          // computed altitude, deg
    let appGHA: Double         // Greenwich Hour Angle, deg
    let appDec: Double         // declination, deg

    var usno: USNOResult?
    var error: String?

    func delta(_ kp: KeyPath<CompareRow, Double>, _ usnoVal: Double?) -> Double? {
        guard let u = usnoVal else { return nil }
        var d = self[keyPath: kp] - u
        if abs(d) > 180 { d -= d.sign == .plus ? 360 : -360 }
        return d
    }

    var znDelta:  Double? { delta(\.appZn, usno?.azimuthDegrees) }
    var hcDelta:  Double? { delta(\.appHc, usno?.altitudeDegrees) }
    var ghaDelta: Double? { delta(\.appGHA, usno?.ghaDegrees) }
    var decDelta: Double? { delta(\.appDec, usno?.decDegrees) }
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
            let q = AlmanacCalculator.compute(bodyID: id, observer: observer)
            guard q.horizontalTrue.altitudeDegrees > 0 else { return nil }
            return CompareRow(
                id: id.id,
                bodyID: id,
                displayName: id.displayName,
                appZn: q.horizontalTrue.azimuthDegrees,
                appHc: q.horizontalTrue.altitudeDegrees,
                appGHA: q.ghaDegrees,
                appDec: AngleMath.radToDeg(q.equatorial.declination)
            )
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
