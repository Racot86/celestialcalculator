import Foundation
import Observation

@Observable
final class BodyDetailViewModel {
    var bodyID: CelestialBodyID
    var observerStore: ObserverStore

    init(bodyID: CelestialBodyID = .sun, observerStore: ObserverStore) {
        self.bodyID = bodyID
        self.observerStore = observerStore
    }

    /// Full almanac-style readout for the selected body at the observer instant
    /// and position. One computation, every quantity the app can supply.
    var almanac: AlmanacQuantities {
        AlmanacCalculator.compute(bodyID: bodyID, observer: observerStore.observer)
    }
}
