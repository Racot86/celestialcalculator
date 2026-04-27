import Foundation
import Observation

@Observable
final class ObserverStore {
    /// Observer state — date, latitude, longitude, elevation. Fully user-controlled.
    /// There is no auto-ticking: the value is exactly what the user sets in the
    /// Observer tab and never changes on its own.
    var observer: Observer

    init(observer: Observer = Observer(date: Date(), latitude: 40.7128, longitude: -74.0060, elevation: 0)) {
        self.observer = observer
    }

    /// Snap to the current wall-clock UT instant once. Does NOT enable any
    /// auto-tracking — calling this is a one-shot.
    func setNow() {
        observer.date = Date()
    }
}
