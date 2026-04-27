import Foundation
import Observation

@Observable
final class ObserverStore {
    var observer: Observer

    init(observer: Observer = Observer(date: Date(), latitude: 40.7128, longitude: -74.0060, elevation: 0)) {
        self.observer = observer
    }

    func setNow() { observer.date = Date() }
}
