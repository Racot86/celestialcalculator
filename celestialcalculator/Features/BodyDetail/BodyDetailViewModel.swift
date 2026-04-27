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

    var horizontal: HorizontalCoordinates {
        BodyFactory.body(for: bodyID).horizontalCoordinates(for: observerStore.observer)
    }

    var equatorial: EquatorialCoordinates {
        let jd = JulianDate.julianDay(from: observerStore.observer.date)
        return BodyFactory.body(for: bodyID).apparentEquatorial(jdUT: jd)
    }
}
