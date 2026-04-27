import Foundation
import Observation

struct BodyAzimuthRow: Identifiable, Hashable {
    let id: String
    let bodyID: CelestialBodyID
    let displayName: String
    let classification: String
    let azimuthDegrees: Double
    let altitudeDegrees: Double
}

@Observable
final class BodiesListViewModel {
    var observerStore: ObserverStore
    var hideBelowHorizon: Bool = false

    init(observerStore: ObserverStore) {
        self.observerStore = observerStore
    }

    var rows: [BodyAzimuthRow] {
        var ids: [CelestialBodyID] = [.sun, .moon]
        ids += PlanetKind.allCases.map { .planet($0) }
        ids += (0..<NavigationalStars.count).map { .star($0) }
        let observer = observerStore.observer
        let computed: [BodyAzimuthRow] = ids.map { id in
            let h = BodyFactory.body(for: id).horizontalCoordinates(for: observer)
            return BodyAzimuthRow(
                id: id.id,
                bodyID: id,
                displayName: id.displayName,
                classification: id.classification,
                azimuthDegrees: h.azimuthDegrees,
                altitudeDegrees: h.altitudeDegrees
            )
        }
        let filtered = hideBelowHorizon ? computed.filter { $0.altitudeDegrees > 0 } : computed
        return filtered
    }
}
